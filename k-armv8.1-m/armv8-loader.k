require "armv8-configuration.k"

module ARMV8-LOADER-SYNTAX
  
endmodule

module ARMV8-LOADER
  imports ARMV8-LOADER-SYNTAX
  imports ARMV8-CONFIGURATION
  
  // Unroll instructions into KList
  rule I:Instruction Is:Instructions => I ~> Is
  
  rule <k> OP:Opcode . S:Label OPR:Operands => . ...</k>
       <instructiontext> code(M:Map => M[L <- storedInstr(OP.S OPR)]) </instructiontext>
       <nextloc> L:MInt => addMInt(L, mi(32, 1)) </nextloc>
  
  /*@
  rule <k> OP:Opcode OPR:Operands => . ...</k>
       <instructiontext> code(M:Map => M[L <- storedInstr(OP OPR)]) </instructiontext>
       <nextloc> L:MInt => addMInt(L, mi(64, 1)) </nextloc>
  */ 
      
  rule <k> .Instructions => .K ...</k>
  
  /*@
    set the begin point
  */
  rule <k> (main:Start:):Beginp => . ...</k>
       <functarget> FMap:Map => FMap[main <- L] </functarget>
       <nextloc> L </nextloc>
       
  
  /*@
    R15 is set to the entry point address corresponding to labels
    "main"
  */
  rule <k> loadBegin => .K ...</k>
       <regstate> RSMap => RSMap["R15" <- LoadAddr] </regstate>
       <begin> _:K => LoadAddr </begin>
       <functarget>... main:Start |-> LoadAddr:MInt ...</functarget>

  /*@
    scan: scan the program and get them, for 4 beat
  */
  rule <k> scan => setDefaultRegs(OP) ~>
    
                   beatResult(OP . S OPR, 0) ~>
                   execinstrBeat(OP . S OPR, 0) ~>
                   registersMessage ~>
                   
                   beatResult(OP . S OPR, 1) ~>
                   execinstrBeat(OP . S OPR, 1) ~>
                   registersMessage ~>
                   
                   beatResult(OP . S OPR, 2) ~>
                   execinstrBeat(OP . S OPR, 2) ~>
                   registersMessage ~>
                   
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
       <instructiontext> code(L |-> storedInstr(OP . S OPR) _:Map) </instructiontext>
       <regstate>... "R15" |-> (L:MInt => addMInt(L, mi(32, 1))) ...</regstate>
         requires notBool (OP ==K exit)
  
  rule <k> scan => execinstr(OP . S OPR) ~> registersMessage ~> scan ...</k>
       <instructiontext> code(L |-> storedInstr(OP . S OPR) _:Map) </instructiontext>
       <regstate>... "R15" |-> (L:MInt => addMInt(L, mi(32, 1))) ...</regstate>
         requires (OP ==K exit)
  
  /*@
    if no more instruction, then exit
  */
  rule <k> scan => . ...</k>
       <instructiontext> code(IMap) </instructiontext>
       <regstate> RSMap </regstate>
         requires notBool {RSMap["R15"]}:>MInt in_keys ( IMap )	// in_keys in stl
         
  rule <k> registersMessage => . ...</k>
       <regstateseq> ... .List => ListItem(RSMap) </regstateseq>
       <regstate> RSMap </regstate>
       <functarget> FMap:Map </functarget>
       <instructiontext> code(IMap) </instructiontext>
         requires {RSMap["R15"]}:>MInt in_keys (IMap)
  
  rule <k> registersMessage => . ...</k>
       <regstateseq> ... .List => ListItem(RSMap) ListItem(FMap) </regstateseq>
       <regstate> RSMap </regstate>
       <functarget> FMap:Map </functarget>
       <instructiontext> code(IMap) </instructiontext>
         requires notBool {RSMap["R15"]}:>MInt in_keys (IMap)
  
  // Exit
  syntax KItem ::= "exit_0"
  rule <k> .K => exit_0 </k>
    
endmodule

