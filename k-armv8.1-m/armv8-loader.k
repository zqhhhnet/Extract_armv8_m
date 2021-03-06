require "armv8-configuration.k"

module ARMV8-LOADER-SYNTAX
  
endmodule

module ARMV8-LOADER
  imports ARMV8-LOADER-SYNTAX
  imports ARMV8-CONFIGURATION
  
  // Unroll instructions into KList
  rule I:Instruction Is:Instructions => I ~> Is
  
  rule <k> OP:Opcode . S:Label OPR:Operands => . ...</k>
       <instructiontext> code(M:Map => M[memloc(L) <- storedInstr(OP.S OPR)]) </instructiontext>
       <nextloc> L:MInt => addMInt(L, mi(32, 1)) </nextloc>
       requires notBool (OP ==K end)
       
  rule <k> OP:Opcode . S:NLabel OPR:Operands => . ...</k>
       <instructiontext> code(M:Map => M[memloc(L) <- storedInstr(OP.S OPR)]) </instructiontext>
       <nextloc> L:MInt => addMInt(L, mi(32, 1)) </nextloc>
       requires notBool (OP ==K end)
  
  
  rule <k> OP:Opcode OPR:Operands => . ...</k>
       <instructiontext> code(M:Map => M[memloc(L) <- storedInstr(OP OPR)]) </instructiontext>
       <nextloc> L:MInt => addMInt(L, mi(32, 1)) </nextloc>
       // requires (OP ==K end)
      
  rule <k> .Instructions => .K ...</k>
  
  /*@
    set the begin point
  */
  rule <k> (start:Start:):Beginp => . ...</k>
       <functarget> FMap:Map => FMap[start <- memloc(L)] </functarget>
       <nextloc> L </nextloc>
       
  
  /*@
    R15 is set to the entry point address corresponding to labels
    "start"
  */
  rule <k> loadBegin => .K ...</k>
       <regstate> RSMap => RSMap["R15" <- LoadAddr] </regstate>
       <begin> _:K => LoadAddr </begin>
       <functarget>... start:Start |-> LoadAddr:MInt ...</functarget>

  /*@
    scan: scan the program and get them, for 4 beat
  */
  rule <k> scan => setDefaultRegs(OP) ~>
                   beatResult(OP . S:Label OPR, 0) ~>
                   execinstrBeat(OP . S:Label OPR, 0) ~>
                   registersMessage ~>
                   
                   setDefaultRegs(OP) ~>
                   beatResult(OP . S OPR, 1) ~>
                   execinstrBeat(OP . S OPR, 1) ~>
                   registersMessage ~>
                   
                   setDefaultRegs(OP) ~>
                   beatResult(OP . S OPR, 2) ~>
                   execinstrBeat(OP . S OPR, 2) ~>
                   registersMessage ~>
                   
                   setDefaultRegs(OP) ~>
                   beatResult(OP . S OPR, 3) ~>
                   execinstrBeat(OP . S OPR, 3) ~>
                   registersMessage ~>
  		    
  		/*
                   beat1Result(OP . S OPR, 0) ~> 
                   execinstr1Beat(OP . S OPR, 0) ~>
                   registersMessage ~> 
                   
                   beat2Result(OP . S OPR) ~>
                   execinstr2Beat(OP . S OPR) ~>
                   registersMessage ~> 
                   
                   beat3Result(OP . S OPR) ~>
                   execinstr3Beat(OP . S OPR) ~>
                   registersMessage ~> 
                   
                   
                   beat4Result(OP . S OPR) ~>
                   execinstr4Beat(OP . S OPR) ~>
                   registersMessage ~>
               */
                   scan ...</k>
       <instructiontext> code(memloc(L) |-> storedInstr(OP . S OPR) _:Map) </instructiontext>
       <regstate>... "R15" |-> (memloc(L:MInt) => memloc(addMInt(L, mi(32, 1)))) ...</regstate>
         requires notBool (OP ==K end)
  
  /*@
    vmov
  */
  rule <k> scan => setDefaultRegs(OP) ~>
    
                   execinstrBeat(OP OPR, 0) ~>
                   registersMessage ~>
                   
                   execinstrBeat(OP OPR, 1) ~>
                   registersMessage ~>
                   
                   execinstrBeat(OP OPR, 2) ~>
                   registersMessage ~>
                   
                   execinstrBeat(OP OPR, 3) ~>
                   registersMessage ~>
  		    
                   scan ...</k>
       <instructiontext> code(memloc(L) |-> storedInstr(OP OPR) _:Map) </instructiontext>
       <regstate>... "R15" |-> (memloc(L:MInt) => memloc(addMInt(L, mi(32, 1)))) ...</regstate>
         requires (OP ==K VMOV)
  
  // for vector lane, store the specific R to one element of Q.
  rule <k> scan => setDefaultRegs(OP) ~>
                   execinstr(OP . S:NLabel OPR) ~>
                   registersMessage ~>
                   scan ...</k>
       <instructiontext> code(memloc(L) |-> storedInstr(OP . S OPR) _:Map) </instructiontext>
       <regstate>... "R15" |-> (memloc(L:MInt) => memloc(addMInt(L, mi(32, 1)))) ...</regstate>
         requires (OP ==K VMOV)
     
  /*@
    mov
  */
  rule <k> scan => setDefaultRegs(OP) ~>
                   execinstr(OP OPR) ~>
                   registersMessage ~>
                   scan ...</k>
       <instructiontext> code(memloc(L) |-> storedInstr(OP OPR) _:Map) </instructiontext>
       <regstate>... "R15" |-> (memloc(L:MInt) => memloc(addMInt(L, mi(32, 1)))) ...</regstate>
         requires (OP ==K MOV) orBool (OP ==K ADD) orBool (OP ==K MAX)
  
  rule <k> scan => execinstr(OP OPR) ~> registersMessage ~> scan ...</k>
       <instructiontext> code(memloc(L) |-> storedInstr(OP OPR) _:Map) </instructiontext>
       <regstate>... "R15" |-> (memloc(L:MInt) => memloc(addMInt(L, mi(32, 1)))) ...</regstate>
         requires (OP ==K end)
  
  /*@
    if no more instruction, then exit
  */
  rule <k> scan => . ...</k>
       <instructiontext> code(IMap) </instructiontext>
       <regstate> RSMap </regstate>
         requires notBool {RSMap["R15"]}:>Ptm in_keys ( IMap )	// in_keys in stl
         
  rule <k> registersMessage => . ...</k>
       <regstateseq> ... .List => ListItem(RSMap) </regstateseq>
       <regstate> RSMap </regstate>
       <functarget> FMap:Map </functarget>
       <instructiontext> code(IMap) </instructiontext>
         requires {RSMap["R15"]}:>Ptm in_keys (IMap)
  
  rule <k> registersMessage => . ...</k>
       <regstateseq> ... .List => ListItem(RSMap) ListItem(FMap) </regstateseq>
       <regstate> RSMap </regstate>
       <functarget> FMap:Map </functarget>
       <instructiontext> code(IMap) </instructiontext>
         requires notBool {RSMap["R15"]}:>Ptm in_keys (IMap)
  
  // end
  syntax KItem ::= "End"
  rule <k> .K => End </k>
    
endmodule

