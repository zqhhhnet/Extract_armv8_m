(**
SimSoC-Cert, a Coq library on processor architectures for embedded systems.
See the COPYRIGHTS and LICENSE files.

Formalization of the ARM architecture version 6 following the:

ARM Architecture Reference Manual, Issue I, July 2005.

Page numbers refer to ARMv6.pdf.

Parser for binary encoding of instructions
*)

(* 
#load "codetype.cmo";; 
#load "dynlink.cma";; 
#load "camlp4o.cma";; 
#load "librap.cmo";;
ocamlc -pp camlp4o
*)

module LR = Librap
module CT = Codetype


(* Sequence of integers separated by white spaces *)
exception Not_seq_int_spaces
let rec seqwhint1 c = parser 
  | [< n = LR.horner (LR.valdigit c); l = seqwhint  >] -> n :: l
  | [< >] -> raise Not_seq_int_spaces
and seqwhint = parser
  | [< '' ' ; s  >] -> seqwhint s
  | [< ''0'..'9'as c; s  >] -> seqwhint1 c s
  | [< >] -> []

(* Special case for fields tagged SBO and SBZ: 1 or several bits -> no simple algo
 * -> for 1 but replaced with !SBZ and !SBO *)
(* Special case for fields tagged H: these fields are 1 bit in ARM but 2 bits in
 * Thumb. They are stored as ARM1Thumb2. Conversely, "imod" fields are stored as
 * ARM2Thumb1. *)
type code_contents = 
  B0 | B1 | Onebit of string | Several of string |
      ARM1Thumb2 of string | ARM2Thumb1 of string

let rec code_contents = parser
  | [< '' ' ; s >] -> code_contents s
  | [< '  '0'..'9' | 'a'..'z'| 'A'..'Z' | '_' | '!' as c; id = LR.ident c >] -> 
      if c = '!' then Onebit (String.sub id 1 (String.length id -1 )) else
	match id with
	  | "0" -> B0
	  | "1" -> B1
	  | "mmod" | "sh" | "H1" | "H2" -> Onebit (id)
          | "H" -> ARM1Thumb2 (id)
          | "imod" -> ARM2Thumb1 (id)
	  | _ -> if String.length id = 1 then Onebit (id) else Several (id)
	    
let rec seq_contents = parser
  | [< t = code_contents; l = seq_contents >] -> t :: l
  | [< >] -> []

type instruction = Instruction of LR.header * int list * code_contents list

let instruction = parser
  | [< h = LR.header;
       li = seqwhint;
       () = LR.skip_empty_line;
       lc = seq_contents;
       () = LR.skip_empty_line
    >] -> Instruction (h, li, lc)

let rec instructions_list = parser
  | [< o = instruction; l = instructions_list >] -> o :: l
  | [< >] -> []

(* For debugging the ARM doc: more robust and provides the reversed result
   so we can see the last successfully parsed instruction
 *)
let rec debug_instructions l s = 
  match (try Some (instruction s) with _ -> None) with
    | Some o -> debug_instructions (o :: l) s
    | None -> l

(* Mapping code_contents to bit numbers *)

type map = CT.pos_contents array

(* Inconsistent (expected index, position list, contents list, map) *)
exception Inconsistent of int * int list * code_contents list * map

(* Checks
  - the position list should decrease from 31 or 15 to 0 without hole
  - the consistency of the position list with code_contents list
*)
let build_map lint lcont =
  let start = List.hd lint in
  let map = Array.make (start+1) (CT.Nothing) in
  let rec loop exp lint lcont =
    (match lint with 
      | x :: _ when x <> exp -> raise (Inconsistent (exp, lint, lcont, map))
      | _ -> ());
    match lint, lcont with
      | x :: y :: lint, Several(id) :: lcont -> 
	  if x<=y then raise (Inconsistent (exp, lint, lcont, map)) else
	    let n = x - y in
	    let f =
	      if id = "SBZ" then (fun i -> CT.Shouldbe (false))
	      else if id = "SBO" then (fun i -> CT.Shouldbe (true))
	      else (fun i -> CT.Range (id, n+1, i)) in
	    for i = 0 to n do map.(y + i) <- f i done;
	    loop (y-1) lint lcont
      | x :: lint,  B0 :: lcont  ->
	  map.(x) <- CT.Value (false); 
	  loop (x-1) lint lcont
      | x :: lint,  B1 :: lcont  ->
	  map.(x) <- CT.Value (true);
	  loop (x-1) lint lcont
      | x :: lint,  Onebit (id) :: lcont  -> 
	  map.(x) <- 
	    if String.length id = 1 then CT.Param1 (id.[0])
	    else if id = "SBZ" then CT.Shouldbe (false)
	    else if id = "SBO" then CT.Shouldbe (true)
	    else CT.Param1s (id);
	  loop (x-1) lint lcont
      | [],  [] -> ()
      | _, _ -> raise (Inconsistent (exp, lint, lcont, map))
  in
  let arm = function
    | ARM2Thumb1 id -> Several id
    | ARM1Thumb2 id -> Onebit id
    | x -> x
  and thumb = function
    | ARM2Thumb1 id -> Onebit id
    | ARM1Thumb2 id -> Several id
    | x -> x
  in
    if start = 31 then loop start lint (List.map arm lcont)
    else if start = 15 then loop start lint (List.map thumb lcont)
    else raise (Inconsistent (start, lint, lcont, map));
    map

let print_err_header (LR.Header (c, n, l, s)) =
  Printf.fprintf stderr "Inconsistent %c%i" c n;
  List.iter (fun n -> Printf.fprintf stderr ".%i" n) l;
  Printf.fprintf stderr " %s\n"s

let rec maplist = function
  | [] -> []
  | Instruction (h, li, lc) :: l -> 
      let k =
	try let b = build_map li lc in fun q -> (LR.light h, b) :: q 
	with Inconsistent (_, _, _, _) ->
	  print_err_header h; fun q -> q in
      k (maplist l)

exception No_exc

type 'a result = OK of 'a | Exn of exn

(* For debugging the ARM doc *)
let rec debug_maplist a = function
  | [] -> No_exc, a
  | Instruction (h, li, lc) :: l ->
       match (try OK (build_map li lc) with e -> Exn(e)) with
	 | Exn (e)  -> e, a
	 | OK (m) -> debug_maplist ((LR.light h, m) :: a) l


(* Returns the intended list of maps,
  where each map is an array of length 32 *)
let main s : CT.maplist =
  let linst = instructions_list s in
  let lmap = maplist linst in
  lmap

let () = 
  let l = main (Stream.of_channel stdin) in
  output_value stdout l

(*

(* tests *)


let () = close_in cin
let cin = open_in "ADCbin.txt"
let s = Stream.of_channel cin
let Instruction(_, lint, lcont) = instruction s
let m = build_map lint lcont

let () = close_in cin
let cin = open_in "bincodeV6.txt"
let s = Stream.of_channel cin
let linst = instructions_list s
let lmap = debug_maplist [] linst

let () = close_in cin
let cin = open_in "bincodeV6.txt"
let s = Stream.of_channel cin
let linst = instructions_list s
let lmap = maplist linst
let () = close_in cin

let bidon = 0

*)
