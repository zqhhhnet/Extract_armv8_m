require "armv8-configuration.k"

module VMAXAV
  imports ARMV8-CONFIGURATION
  
  rule <k> setDefaultRegs(VMAXAV:Opcode) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           "CONTROL" |-> mi(32, 1)
           "CONTROL_S" |-> mi(32, 1)
           "CONTROL_NS" |-> mi(32, 1)
           "CPACR" |-> mi(32, 3145728)
           "CPACR_S" |-> mi(32, 3145728)
           "CPACR_NS" |-> mi(32, 3145728)
           "NSACR" |-> mi(32, 1024)
           "CPPWR" |-> mi(32, 0)
           "CPPWR_NS" |-> mi(32, 0)
           "CPPWR_S" |-> mi(32, 0)
           "MVFR1" |-> mi(32, 256)
           "EPSR" |-> mi(32, 2048)
           "FPCCR" |-> mi(32, 0)
           "FPCCR_S" |-> mi(32, 0)
           "FPCCR_NS" |-> mi(32, 0)
           "VPR" |-> mi(32, 2048)
           "RESULT" |-> mi(32, 0)
         )
       </regstate>
  
  /*@
    signExtend
   */
  rule <k> beatResult(VMAXAV:Opcode . S:Label Rd:R32, Qm:Q128, Operands, I:Int) => . 
       ...</k>
       
       <regstate>
         RSMap:Map => updateMap(RSMap,
           "RESULT" |-> (ifMInt (S ==K S8) then signExtend((LeftAbsMaxMIntOfInt(extractMInt(getVecParentValue(Qm, I, RSMap), 0, 8), (LeftAbsMaxMIntOfInt(extractMInt(getVecParentValue(Qm, I, RSMap), 8, 16), (LeftAbsMaxMIntOfInt(extractMInt(getVecParentValue(Qm, I, RSMap), 16, 24), (LeftAbsMaxMIntOfInt(extractMInt(getVecParentValue(Qm, I, RSMap), 24, 32), (extractMInt(getParentValue(Rd, RSMap), 24, 32)), 8, RSMap)), 8, RSMap)), 8, RSMap)), 8, RSMap)), 32) else (ifMInt (S ==K S16) then signExtend((LeftAbsMaxMIntOfInt(extractMInt(getVecParentValue(Qm, I, RSMap), 0, 16), (LeftAbsMaxMIntOfInt(extractMInt(getVecParentValue(Qm, I, RSMap), 16, 32), (extractMInt(getParentValue(Rd, RSMap), 16, 32)), 16, RSMap)), 16, RSMap)), 32) else (ifMInt (S ==K S32) then signExtend((LeftAbsMaxMIntOfInt(extractMInt(getVecParentValue(Qm, I, RSMap), 0, 32), (getParentValue(Rd, RSMap)), 32, RSMap)), 32) else (undefMInt32) ) ) )
         )
       
       </regstate>
  
  rule <k> execinstrBeat(VMAXAV:Opcode . S:Label Rd:R32, Qm:Q128, .Operands, I:Int) => . 
       ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           convToRegKeys(Rd) |-> getParentValue(result, RSMap)
         )
         
       </regstate>
  
  
endmodule
