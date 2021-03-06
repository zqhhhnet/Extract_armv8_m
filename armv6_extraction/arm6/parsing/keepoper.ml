(**
SimSoC-Cert, a Coq library on processor architectures for embedded systems.
See the COPYRIGHTS and LICENSE files.

Formalization of the ARM architecture version 6 following the:

ARM Architecture Reference Manual, Issue I, July 2005.

Page numbers refer to ARMv6.pdf.

Selection of pseudo-code for instructions in the ARM manual, txt format
*)

(* 
#load "dynlink.cma";; 
#load "camlp4o.cma";; 
#load "librap.cmo";;
ocamlc -pp camlp4o
*)

module LR = Librap

(* Strings used for locating the beginning of interesting parts *)
(* modified by hhh
let alpha = "Alphabetical list of ARM instructions"
let alphathumb = "Alphabetical list of Thumb instructions"
let genotes = "General notes"
let addrmodes = "Addressing Mode "
let beforeopdescr = "Shifted register operand value"
*)
(* modified by hhh Set start bound *)
let alpha = "Alphabetical list of instructions"
let fir = "VLSTM"
(* modified by hhh Set end bound *)
let end_num = 379
let blanks_add = "          "

let to_next_Ainstr = LR.to_given_header (LR.filpart 'C')

(*
let rec in_operation = parser 
  | [< ''\n'; s >] -> in_operation1 s
  | [< 'c; a = LR.take_eol c; s >] -> 
    print_endline a; in_operation s
and in_operation1 = parser 
  | [< ''\n' >] -> ()
  | [< 'c; a = LR.take_eol c; s >] ->
    print_endline a; in_operation s
*)

(* modified by hhh *)
let rec in_operation = parser
  | [< ''\n'; s >] -> in_operation1 0 s
  | [< 'c; a = LR.take_eol c; s>] ->
    print_endline a; in_operation s 
and in_operation1 n = parser
  | [< ''\n'; s >] -> 
    begin
      (* n = n + 1; *)
      if n = 0 then in_operation1 1 s
      else if n = 1 then ()
      else if n = 2 then in_operation2 0 s
      else ()
    end
  | [< 'c; () = LR.skip_line; s>] -> in_operation1 2 s
and in_operation2 n = parser
  | [< ''\n'; s >] ->
    begin
      (* n = n + 1; *)
      if n = 0 then in_operation2 1 s
      else ()
    end
  | [< '' '; s >] -> in_operation3 s
  | [< >] -> ()
and in_operation3 = parser
  | [< '' '; s >] -> in_operation3 s
  | [< ''0'..'9' as c; a = LR.take_eol c; s >] ->
    print_string blanks_add; print_endline a; in_operation3 s;
  | [< ''\n'>] -> ()

(* Only part A is considered in ARM manual *)
(* modified by hhh Only part C is considered in ARM manual *)

type stop_ou_encore = Stop | Continue | Op of LR.header 
exception PB_check_then_to_operation_or_next_header

let rec to_operation_or_next_header h = parser
  | [< ba = LR.blanks_alpha; s >] ->
      (match ba with 
      | LR.NH "Operation for all encodings" -> Op h
      | LR.NH _ -> to_operation_or_next_header h s
      | LR.SH h1 -> check_then_to_operation_or_next_header h1 s )
  | [< () = LR.eat_eol; s >] -> to_operation_or_next_header h s
and check_then_to_operation_or_next_header h s = 
      if LR.filend end_num h then Stop
      else if LR.filpart 'C' h then to_operation_or_next_header h s
      else Continue
      (* modified by hhh
      if LR.filpart 'A' h then to_operation_or_next_header h s
      else if LR.filendinstr h then Stop
      else Continue
      *)


let rec loop_instrs = parser
  | [< h = LR.to_next_header; s >] -> 
      (match check_then_to_operation_or_next_header h s with
	 | Op h1 -> 
	     begin
	       LR.print_header h1;
	       in_operation s;
               loop_instrs s
	     end
	 | Stop -> ()
	 | Continue -> loop_instrs s
       )

let main = parser 
    [< _ = LR.to_given_header (LR.filtitle alpha);
    (* modified by hhh
       _ = LR.to_given_header (LR.filtitle genotes);
    *)
       _ = LR.to_given_header (LR.filtitle fir);
       () = loop_instrs;
       (* modified by hhh
       _ = LR.to_given_header (LR.preftitle addrmodes);
       (* 5 consecutive sections to analyze *)
       () = loop_instrs;
       () = loop_instrs;
       () = loop_instrs;
       () = loop_instrs;
       () = loop_instrs;
       _ = LR.to_given_header (LR.filtitle alphathumb);
       _ = LR.to_given_header (LR.filtitle genotes);
       () = loop_instrs;
       *)
    >]
  -> ()

let () = main (Stream.of_channel stdin)

(*

let cin = open_in "ARMv6.txt"
let cin = open_in "ADC.txt"
let s = Stream.of_channel cin
let test = to_given_header (filtitle alpha) s
let test = to_given_header (filtitle genotes) s
let test = loop_instrs s
let () = close_in cin


*)
