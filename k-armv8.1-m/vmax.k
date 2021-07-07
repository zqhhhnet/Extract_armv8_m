require "armv8-configuration.k"

module VMAX
  imports ARMV8-CONFIGURATION
  
  rule <k> setDefaultRegs(vmax:Opcode) => . ...</k>
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
         )
       </regstate>
  
  /*@
    the first beat
  */
  
  rule <k> beat1Result(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, Operands) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
         "RESULT" |->  /* the first beat lowest 32b */ (ifMInt (((((((eqMInt(extractMInt(getReg("CONTROL", RSMap), 31, 32), mi(1,1)) andBool (eqMInt(extractMInt(getReg("CPACR", RSMap), 10, 12), mi(2,3)) andBool (eqMInt(extractMInt(getReg("NSACR", RSMap), 21, 22), mi(1,1))))) andBool eqMInt(extractMInt(getReg("CPPWR", RSMap), 11, 12), mi(1,0))) andBool neMInt(extractMInt(getReg("MVFR1", RSMap), 20, 24), mi(4,0))) andBool (eqMInt(extractMInt(getReg("EPSR", RSMap), 5, 7), mi(2,0)) andBool eqMInt(extractMInt(getReg("EPSR", RSMap), 16, 22), mi(6,2)))) andBool (eqMInt(extractMInt(getReg("FPCCR", RSMap), 31, 32), mi(1,0)) andBool eqMInt(extractMInt(getReg("FPCCR", RSMap), 0, 1), mi(1,0)))) andBool eqMInt(extractMInt(getReg("CONTROL", RSMap), 29, 30), mi(1,0))) andBool eqMInt(extractMInt(getReg("VPR", RSMap), 20, 21), mi(1,1)) ) then ( ifMInt (S ==K S8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 120, 128), extractMInt(getParentValue(Qn, RSMap), 120, 128)) then (extractMInt(getParentValue(Qm, RSMap), 120, 128)) else (extractMInt(getParentValue(Qn, RSMap), 120, 128)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 112, 120), extractMInt(getParentValue(Qn, RSMap), 112, 120)) then (extractMInt(getParentValue(Qm, RSMap), 112, 120)) else (extractMInt(getParentValue(Qn, RSMap), 112, 120)) ) , 8)  ) , (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 104, 112), extractMInt(getParentValue(Qn, RSMap), 104, 112)) then (extractMInt(getParentValue(Qm, RSMap), 104, 112)) else (extractMInt(getParentValue(Qn, RSMap), 104, 112)) ) , 16) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 96, 104), extractMInt(getParentValue(Qn, RSMap), 96, 104)) then (extractMInt(getParentValue(Qm, RSMap), 96, 104)) else (extractMInt(getParentValue(Qn, RSMap), 96, 104)) ), 24) ) 
             else ( ifMInt (S ==K U8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 120, 128), extractMInt(getParentValue(Qn, RSMap), 120, 128)) then (extractMInt(getParentValue(Qm, RSMap), 120, 128)) else (extractMInt(getParentValue(Qn, RSMap), 120, 128)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 112, 120), extractMInt(getParentValue(Qn, RSMap), 112, 120)) then (extractMInt(getParentValue(Qm, RSMap), 112, 120)) else (extractMInt(getParentValue(Qn, RSMap), 112, 120)) ) , 8)  ) , (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 104, 112), extractMInt(getParentValue(Qn, RSMap), 104, 112)) then (extractMInt(getParentValue(Qm, RSMap), 104, 112)) else (extractMInt(getParentValue(Qn, RSMap), 104, 112)) ) , 16) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 96, 104), extractMInt(getParentValue(Qn, RSMap), 96, 104)) then (extractMInt(getParentValue(Qm, RSMap), 96, 104)) else (extractMInt(getParentValue(Qn, RSMap), 96, 104)) ), 24) ) 
             else ( ifMInt (S ==K S16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 112, 128), extractMInt(getParentValue(Qn, RSMap), 112, 128)) then (extractMInt(getParentValue(Qm, RSMap), 112, 128)) else (extractMInt(getParentValue(Qn, RSMap), 112, 128)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 96, 112), extractMInt(getParentValue(Qn, RSMap), 96, 112)) then (extractMInt(getParentValue(Qm, RSMap), 96, 112)) else (extractMInt(getParentValue(Qn, RSMap), 96, 112)) ) , 16) ) 
             else ( ifMInt (S ==K U16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 112, 128), extractMInt(getParentValue(Qn, RSMap), 112, 128)) then (extractMInt(getParentValue(Qm, RSMap), 112, 128)) else (extractMInt(getParentValue(Qn, RSMap), 112, 128)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 96, 112), extractMInt(getParentValue(Qn, RSMap), 96, 112)) then (extractMInt(getParentValue(Qm, RSMap), 96, 112)) else (extractMInt(getParentValue(Qn, RSMap), 96, 112)) ) , 16) ) 
             else ( ifMInt (S ==K S32) then (plugInMask(mi(32, 0), (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 96, 128), extractMInt(getParentValue(Qn, RSMap), 96, 128)) then (extractMInt(getParentValue(Qm, RSMap), 96, 128)) else (extractMInt(getParentValue(Qn, RSMap), 96, 128)) ) , 0)) 
             else ( ifMInt (S ==K U32) then (plugInMask(mi(32, 0), (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 96, 128), extractMInt(getParentValue(Qn, RSMap), 96, 128)) then (extractMInt(getParentValue(Qm, RSMap), 96, 128)) else (extractMInt(getParentValue(Qn, RSMap), 96, 128)) ) , 0)) 
             else (mi(32, -1)) ) ) ) ) ) 
           ) else (mi(32, -1))
           )
         )
       </regstate>
  
  rule <k> execinstr1Beat(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, .Operands) => . 
       ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           convToRegKeys(Qd) |-> /* store 32 bit of result to lowest 32 bit of Qd */ ifMInt (neMInt(getParentValue(result, RSMap), mi(32, -1))) then ( plugInMask( ( /* finish [23:0] */ plugInMask( ( /* finish [15:0] */ plugInMask( (/* finish [7:0] */ plugInMask( getParentValue(Qd, RSMap) , extractMInt(getParentValue(result, RSMap), 24, 32) , 0) ) , extractMInt(getParentValue(result, RSMap), 16, 24) , 8) ) , extractMInt(getParentValue(result, RSMap), 8, 16) , 16) ) , extractMInt(getParentValue(result, RSMap), 0, 8) , 24) )
           else (mi(128, -1))
         )
       </regstate>
  
  /*@
    the second beat
  */
  rule <k> beat2Result(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, Operands) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
         "RESULT" |->  /* the second beat lowest 32b */ ( ifMInt (((((((eqMInt(extractMInt(getReg("CONTROL", RSMap), 31, 32), mi(1,1)) andBool (eqMInt(extractMInt(getReg("CPACR", RSMap), 10, 12), mi(2,3)) andBool (eqMInt(extractMInt(getReg("NSACR", RSMap), 21, 22), mi(1,1))))) andBool eqMInt(extractMInt(getReg("CPPWR", RSMap), 11, 12), mi(1,0))) andBool neMInt(extractMInt(getReg("MVFR1", RSMap), 20, 24), mi(4,0))) andBool (eqMInt(extractMInt(getReg("EPSR", RSMap), 5, 7), mi(2,0)) andBool eqMInt(extractMInt(getReg("EPSR", RSMap), 16, 22), mi(6,2)))) andBool (eqMInt(extractMInt(getReg("FPCCR", RSMap), 31, 32), mi(1,0)) andBool eqMInt(extractMInt(getReg("FPCCR", RSMap), 0, 1), mi(1,0)))) andBool eqMInt(extractMInt(getReg("CONTROL", RSMap), 29, 30), mi(1,0))) andBool eqMInt(extractMInt(getReg("VPR", RSMap), 20, 21), mi(1,1)) ) then ( ifMInt (S ==K S8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 88, 96), extractMInt(getParentValue(Qn, RSMap), 88, 96)) then (extractMInt(getParentValue(Qm, RSMap), 88, 96)) else (extractMInt(getParentValue(Qn, RSMap), 88, 96)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 80, 88), extractMInt(getParentValue(Qn, RSMap), 80, 88)) then (extractMInt(getParentValue(Qm, RSMap), 80, 88)) else (extractMInt(getParentValue(Qn, RSMap), 80, 88)) ) , 8)  ) , (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 72, 80), extractMInt(getParentValue(Qn, RSMap), 72, 80)) then (extractMInt(getParentValue(Qm, RSMap), 72, 80)) else (extractMInt(getParentValue(Qn, RSMap), 72, 80)) ) , 16) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 64, 72), extractMInt(getParentValue(Qn, RSMap), 64, 72)) then (extractMInt(getParentValue(Qm, RSMap), 64, 72)) else (extractMInt(getParentValue(Qn, RSMap), 64, 72)) ), 24) ) 
             else ( ifMInt (S ==K U8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 88, 96), extractMInt(getParentValue(Qn, RSMap), 88, 96)) then (extractMInt(getParentValue(Qm, RSMap), 88, 96)) else (extractMInt(getParentValue(Qn, RSMap), 88, 96)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 80, 88), extractMInt(getParentValue(Qn, RSMap), 80, 88)) then (extractMInt(getParentValue(Qm, RSMap), 80, 88)) else (extractMInt(getParentValue(Qn, RSMap), 80, 88)) ) , 8)  ) , (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 72, 80), extractMInt(getParentValue(Qn, RSMap), 72, 80)) then (extractMInt(getParentValue(Qm, RSMap), 72, 80)) else (extractMInt(getParentValue(Qn, RSMap), 72, 80)) ) , 16) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 64, 72), extractMInt(getParentValue(Qn, RSMap), 64, 72)) then (extractMInt(getParentValue(Qm, RSMap), 64, 72)) else (extractMInt(getParentValue(Qn, RSMap), 64, 72)) ), 24) ) 
             else ( ifMInt (S ==K S16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 80, 96), extractMInt(getParentValue(Qn, RSMap), 80, 96)) then (extractMInt(getParentValue(Qm, RSMap), 80, 96)) else (extractMInt(getParentValue(Qn, RSMap), 80, 96)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 64, 80), extractMInt(getParentValue(Qn, RSMap), 64, 80)) then (extractMInt(getParentValue(Qm, RSMap), 64, 80)) else (extractMInt(getParentValue(Qn, RSMap), 64, 80)) ) , 16) ) 
             else ( ifMInt (S ==K U16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 80, 96), extractMInt(getParentValue(Qn, RSMap), 80, 96)) then (extractMInt(getParentValue(Qm, RSMap), 80, 96)) else (extractMInt(getParentValue(Qn, RSMap), 80, 96)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 64, 80), extractMInt(getParentValue(Qn, RSMap), 64, 80)) then (extractMInt(getParentValue(Qm, RSMap), 64, 80)) else (extractMInt(getParentValue(Qn, RSMap), 64, 80)) ) , 16) ) 
             else ( ifMInt (S ==K S32) then (plugInMask(mi(32, 0), (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 64, 96), extractMInt(getParentValue(Qn, RSMap),64, 96)) then (extractMInt(getParentValue(Qm, RSMap), 64, 96)) else (extractMInt(getParentValue(Qn, RSMap), 64, 96)) ) , 0)) 
             else ( ifMInt (S ==K U32) then (plugInMask(mi(32, 0), (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 64, 96), extractMInt(getParentValue(Qn, RSMap), 64, 96)) then (extractMInt(getParentValue(Qm, RSMap), 64, 96)) else (extractMInt(getParentValue(Qn, RSMap), 64, 96)) ) , 0)) 
             else (mi(32, -1)) ) ) ) ) ) 
           ) else (mi(32, -1))
           )
         )
       </regstate>
  
  rule <k> execinstr2Beat(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, .Operands) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           convToRegKeys(Qd) |-> /* store 32 bit of result to lowest 32 bit of Qd */ ifMInt (neMInt(getParentValue(result, RSMap), mi(32, -1))) then ( plugInMask( ( /* finish [23:0] */ plugInMask( ( /* finish [15:0] */ plugInMask( (/* finish [7:0] */ plugInMask( getParentValue(Qd, RSMap) , extractMInt(getParentValue(result, RSMap), 24, 32) , 32) ) , extractMInt(getParentValue(result, RSMap), 16, 24) , 40) ) , extractMInt(getParentValue(result, RSMap), 8, 16) , 48) ) , extractMInt(getParentValue(result, RSMap), 0, 8) , 56) ) 
           else (mi(128, -1))
         )
       </regstate>
  
  /*@
    the last beat
  */
  rule <k> beat3Result(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, Operands) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
         "RESULT" |->  /* the second beat lowest 32b */ (ifMInt (((((((eqMInt(extractMInt(getReg("CONTROL", RSMap), 31, 32), mi(1,1)) andBool (eqMInt(extractMInt(getReg("CPACR", RSMap), 10, 12), mi(2,3)) andBool (eqMInt(extractMInt(getReg("NSACR", RSMap), 21, 22), mi(1,1))))) andBool eqMInt(extractMInt(getReg("CPPWR", RSMap), 11, 12), mi(1,0))) andBool neMInt(extractMInt(getReg("MVFR1", RSMap), 20, 24), mi(4,0))) andBool (eqMInt(extractMInt(getReg("EPSR", RSMap), 5, 7), mi(2,0)) andBool eqMInt(extractMInt(getReg("EPSR", RSMap), 16, 22), mi(6,2)))) andBool (eqMInt(extractMInt(getReg("FPCCR", RSMap), 31, 32), mi(1,0)) andBool eqMInt(extractMInt(getReg("FPCCR", RSMap), 0, 1), mi(1,0)))) andBool eqMInt(extractMInt(getReg("CONTROL", RSMap), 29, 30), mi(1,0))) andBool eqMInt(extractMInt(getReg("VPR", RSMap), 20, 21), mi(1,1)) ) then ( ifMInt (S ==K S8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 56, 64), extractMInt(getParentValue(Qn, RSMap), 56,64)) then (extractMInt(getParentValue(Qm, RSMap), 56, 64)) else (extractMInt(getParentValue(Qn, RSMap), 56, 64)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 48, 56), extractMInt(getParentValue(Qn, RSMap), 48, 56)) then (extractMInt(getParentValue(Qm, RSMap), 48, 56)) else (extractMInt(getParentValue(Qn, RSMap), 48, 56)) ) , 8)  ) , (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 40, 48), extractMInt(getParentValue(Qn, RSMap), 40, 48)) then (extractMInt(getParentValue(Qm, RSMap), 40, 48)) else (extractMInt(getParentValue(Qn, RSMap), 40, 48)) ) , 16) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 32, 40), extractMInt(getParentValue(Qn, RSMap), 32, 40)) then (extractMInt(getParentValue(Qm, RSMap), 32, 40)) else (extractMInt(getParentValue(Qn, RSMap), 32, 40)) ), 24) ) 
             else ( ifMInt (S ==K U8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 56, 64), extractMInt(getParentValue(Qn, RSMap), 56, 64)) then (extractMInt(getParentValue(Qm, RSMap), 56, 64)) else (extractMInt(getParentValue(Qn, RSMap), 56, 64)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 48, 56), extractMInt(getParentValue(Qn, RSMap), 48, 56)) then (extractMInt(getParentValue(Qm, RSMap), 48, 56)) else (extractMInt(getParentValue(Qn, RSMap), 48, 56)) ) , 8)  ) , (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 40, 48), extractMInt(getParentValue(Qn, RSMap), 40, 48)) then (extractMInt(getParentValue(Qm, RSMap), 40, 48)) else (extractMInt(getParentValue(Qn, RSMap), 40, 48)) ) , 16) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 32, 40), extractMInt(getParentValue(Qn, RSMap), 32, 40)) then (extractMInt(getParentValue(Qm, RSMap), 32, 40)) else (extractMInt(getParentValue(Qn, RSMap), 32, 40)) ), 24) ) 
             else ( ifMInt (S ==K S16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 48, 64), extractMInt(getParentValue(Qn, RSMap), 48, 64)) then (extractMInt(getParentValue(Qm, RSMap), 48, 64)) else (extractMInt(getParentValue(Qn, RSMap), 48, 64)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 32, 48), extractMInt(getParentValue(Qn, RSMap), 32, 48)) then (extractMInt(getParentValue(Qm, RSMap), 32, 48)) else (extractMInt(getParentValue(Qn, RSMap), 32, 48)) ) , 16) ) 
             else ( ifMInt (S ==K U16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 48, 64), extractMInt(getParentValue(Qn, RSMap), 48, 64)) then (extractMInt(getParentValue(Qm, RSMap), 48, 64)) else (extractMInt(getParentValue(Qn, RSMap), 48, 64)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 32, 48), extractMInt(getParentValue(Qn, RSMap), 32, 48)) then (extractMInt(getParentValue(Qm, RSMap), 32, 48)) else (extractMInt(getParentValue(Qn, RSMap), 32, 48)) ) , 16) ) 
             else ( ifMInt (S ==K S32) then (plugInMask(mi(32, 0), (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 32, 64), extractMInt(getParentValue(Qn, RSMap),32, 64)) then (extractMInt(getParentValue(Qm, RSMap), 32, 64)) else (extractMInt(getParentValue(Qn, RSMap), 32, 64)) ) , 0)) 
             else ( ifMInt (S ==K U32) then (plugInMask(mi(32, 0), (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 32, 64), extractMInt(getParentValue(Qn, RSMap), 32, 64)) then (extractMInt(getParentValue(Qm, RSMap), 32, 64)) else (extractMInt(getParentValue(Qn, RSMap), 32, 64)) ) , 0)) 
             else (mi(32, -1)) ) ) ) ) ) 
           ) else (mi(32, -1))
           )
         )
       </regstate>
  
  rule <k> execinstr3Beat(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, .Operands) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           convToRegKeys(Qd) |-> /* store 32 bit of result to lowest 32 bit of Qd */ ifMInt (neMInt(getParentValue(result, RSMap), mi(32, -1))) then ( plugInMask( ( /* finish [23:0] */ plugInMask( ( /* finish [15:0] */ plugInMask( (/* finish [7:0] */ plugInMask(getParentValue(Qd, RSMap) , extractMInt(getParentValue(result, RSMap), 24, 32) , 64) ) , extractMInt(getParentValue(result, RSMap), 16, 24) , 72) ) , extractMInt(getParentValue(result, RSMap), 8, 16) , 80) ) , extractMInt(getParentValue(result, RSMap), 0, 8) , 88) ) 
           else (mi(128, -1))
         )
       </regstate>
  
  /*@
    the last beat
  */
  rule <k> beat4Result(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, Operands) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
         "RESULT" |->  /* the second beat lowest 32b */ ( ifMInt (((((((eqMInt(extractMInt(getReg("CONTROL", RSMap), 31, 32), mi(1,1)) andBool (eqMInt(extractMInt(getReg("CPACR", RSMap), 10, 12), mi(2,3)) andBool (eqMInt(extractMInt(getReg("NSACR", RSMap), 21, 22), mi(1,1))))) andBool eqMInt(extractMInt(getReg("CPPWR", RSMap), 11, 12), mi(1,0))) andBool neMInt(extractMInt(getReg("MVFR1", RSMap), 20, 24), mi(4,0))) andBool (eqMInt(extractMInt(getReg("EPSR", RSMap), 5, 7), mi(2,0)) andBool eqMInt(extractMInt(getReg("EPSR", RSMap), 16, 22), mi(6,2)))) andBool (eqMInt(extractMInt(getReg("FPCCR", RSMap), 31, 32), mi(1,0)) andBool eqMInt(extractMInt(getReg("FPCCR", RSMap), 0, 1), mi(1,0)))) andBool eqMInt(extractMInt(getReg("CONTROL", RSMap), 29, 30), mi(1,0))) andBool eqMInt(extractMInt(getReg("VPR", RSMap), 20, 21), mi(1,1)) ) then ( ifMInt (S ==K S8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 24, 32), extractMInt(getParentValue(Qn, RSMap), 24,32)) then (extractMInt(getParentValue(Qm, RSMap), 24, 32)) else (extractMInt(getParentValue(Qn, RSMap), 24, 32)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 16, 24), extractMInt(getParentValue(Qn, RSMap), 16, 24)) then (extractMInt(getParentValue(Qm, RSMap), 16, 24)) else (extractMInt(getParentValue(Qn, RSMap), 16, 24)) ) , 8)  ) , (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 8, 16), extractMInt(getParentValue(Qn, RSMap), 8, 16)) then (extractMInt(getParentValue(Qm, RSMap), 8, 16)) else (extractMInt(getParentValue(Qn, RSMap), 8, 16)) ) , 16) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 0, 8), extractMInt(getParentValue(Qn, RSMap), 0, 8)) then (extractMInt(getParentValue(Qm, RSMap), 0, 8)) else (extractMInt(getParentValue(Qn, RSMap), 0, 8)) ), 24) ) 
             else ( ifMInt (S ==K U8) then ( plugInMask( ( /* finish insert [23:0] */ plugInMask( ( /* finish insert [15:0] */ plugInMask( (/* finish insert [7:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 24, 32), extractMInt(getParentValue(Qn, RSMap), 24, 32)) then (extractMInt(getParentValue(Qm, RSMap), 24, 32)) else (extractMInt(getParentValue(Qn, RSMap), 24, 32)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 16, 24), extractMInt(getParentValue(Qn, RSMap), 16, 24)) then (extractMInt(getParentValue(Qm, RSMap), 16, 24)) else (extractMInt(getParentValue(Qn, RSMap), 16, 24)) ) , 8)  ) , (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 8, 16), extractMInt(getParentValue(Qn, RSMap), 8, 16)) then (extractMInt(getParentValue(Qm, RSMap), 8, 16)) else (extractMInt(getParentValue(Qn, RSMap), 8, 16)) ) , 16) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 0, 8), extractMInt(getParentValue(Qn, RSMap), 0, 8)) then (extractMInt(getParentValue(Qm, RSMap), 0, 8)) else (extractMInt(getParentValue(Qn, RSMap), 0, 8)) ), 24) ) 
             else ( ifMInt (S ==K S16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 16, 32), extractMInt(getParentValue(Qn, RSMap), 16, 32)) then (extractMInt(getParentValue(Qm, RSMap), 16, 32)) else (extractMInt(getParentValue(Qn, RSMap), 16, 32)) ) , 0 ) ) , ( ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 0, 16), extractMInt(getParentValue(Qn, RSMap), 0, 16)) then (extractMInt(getParentValue(Qm, RSMap), 0, 16)) else (extractMInt(getParentValue(Qn, RSMap), 0, 16)) ) , 16) ) 
             else ( ifMInt (S ==K U16) then ( plugInMask( (/* finish insert [15:0] */ plugInMask( mi(32, 0) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 16, 32), extractMInt(getParentValue(Qn, RSMap), 16, 32)) then (extractMInt(getParentValue(Qm, RSMap), 16, 32)) else (extractMInt(getParentValue(Qn, RSMap), 16, 32)) ) , 0 ) ) , ( ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 0, 16), extractMInt(getParentValue(Qn, RSMap), 0, 16)) then (extractMInt(getParentValue(Qm, RSMap), 0, 16)) else (extractMInt(getParentValue(Qn, RSMap), 0, 16)) ) , 16) ) 
             else ( ifMInt (S ==K S32) then (plugInMask(mi(32, 0), (ifMInt sgeMInt( extractMInt(getParentValue(Qm, RSMap), 0, 32), extractMInt(getParentValue(Qn, RSMap),0, 32)) then (extractMInt(getParentValue(Qm, RSMap), 0, 32)) else (extractMInt(getParentValue(Qn, RSMap), 0, 32)) ) , 0)) 
             else ( ifMInt (S ==K U32) then (plugInMask(mi(32, 0), (ifMInt ugeMInt( extractMInt(getParentValue(Qm, RSMap), 0, 32), extractMInt(getParentValue(Qn, RSMap), 0, 32)) then (extractMInt(getParentValue(Qm, RSMap), 0, 32)) else (extractMInt(getParentValue(Qn, RSMap), 0, 32)) ) , 0)) 
             else (mi(32, -1)) ) ) ) ) ) 
           ) else (mi(32, -1))
           )
         )
       </regstate>
  
  rule <k> execinstr4Beat(vmax:Opcode . S:Label Qd:Q128, Qn:Q128, Qm:Q128, .Operands) => . ...</k>
       <regstate>
         RSMap:Map => updateMap(RSMap,
           convToRegKeys(Qd) |-> /* store 32 bit of result to lowest 32 bit of Qd */ ifMInt (neMInt(getParentValue(result, RSMap), mi(32, -1))) then ( plugInMask( ( /* finish [23:0] */ plugInMask( ( /* finish [15:0] */ plugInMask( (/* finish [7:0] */ plugInMask(getParentValue(Qd, RSMap) , extractMInt(getParentValue(result, RSMap), 24, 32) , 96) ) , extractMInt(getParentValue(result, RSMap), 16, 24) , 104) ) , extractMInt(getParentValue(result, RSMap), 8, 16) , 112) ) , extractMInt(getParentValue(result, RSMap), 0, 8) , 120) ) 
           else (mi(128, -1))
         )
       </regstate>
  
endmodule
