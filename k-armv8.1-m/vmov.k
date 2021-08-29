require "armv8-configuration.k"

module VMOV
  imports ARMV8-CONFIGURATION
  
  rule <k> setDefaultRegs(VMOV:Opcode) => . ...</k>
       <regstate> 
       RSMap:Map => updateMap(RSMap,
           "RESULT" |-> mi(32, 0)
           "RESULT64" |-> mi(64, 0)
         )
       
       </regstate>
  
  rule <k> execinstrBeat(VMOV:Opcode Qd:Q128, Imm128:Imm, .Operands, I:Int) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           convToRegKeys(Qd) |-> mi(128, modImm128(Imm128))
         
           convVecToRegKeys(Qd, I) |-> extractMInt(Imm2MInt(Imm128, 128, 128), (96 -Int 32 *Int I), (128 -Int 32 *Int I))
         
       )
       </regstate>
       
  rule <k> execinstrBeat(VMOV:Opcode Qd:Q128, Qs:Q128, .Operands, I:Int) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           convVecToRegKeys(Qd, I) |-> getVecParentValue(Qs, I, RSMap)
         )
       </regstate>
endmodule
