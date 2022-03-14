/*@
    compare of max or min
*/

require "armv8-configuration.k"

module CMP
  imports ARMV8-CONFIGURATION
  
  /*
  rule <k> setDefaultRegs(dtc:StepCommand) => . ... </k>
       <regstate>
         RSMap:Map
       </regstate>
  */
  
  /*@
    when I equal to 0, cmp gets max one,
    cmp gets min others.
  */
  rule <k> execinstr(cmp:StepCommand . S:Label Rd:R32, Qd:Q128, (# I:Int):Imm, .Operands) => . 
       ...</k>
       <regstate> RSMap:Map => updateMap(RSMap,
         "RESULT" |-> ifMInt (I ==Int 0) then ( ifMInt (getRegI("V_TEMP1", RSMap) <=Int getRegI("V_TEMP2", RSMap)) then (signExtend( (ifMInt ((S ==K S8) orBool (S ==K U8)) then mi(8, getRegI("V_TEMP2", RSMap)) else (ifMInt ((S ==K S16) orBool (S ==K U16)) then mi(16, getRegI("V_TEMP2", RSMap)) else (ifMInt ((S ==K S32) orBool (S ==K U32)) then (mi(32, getRegI("V_TEMP2", RSMap))) else (undefMInt) ))), 32)) else ( signExtend( (ifMInt ((S ==K S8) orBool (S ==K U8)) then mi(8, getRegI("V_TEMP1", RSMap)) else (ifMInt ((S ==K S16) orBool (S ==K U16)) then mi(16, getRegI("V_TEMP1", RSMap)) else (ifMInt ((S ==K S32) orBool (S ==K U32)) then (mi(32, getRegI("V_TEMP1", RSMap))) else (undefMInt) ))), 32) ) ) else ( ifMInt (getRegI("V_TEMP1", RSMap) <=Int getRegI("V_TEMP2", RSMap)) then (signExtend( (ifMInt ((S ==K S8) orBool (S ==K U8)) then mi(8, getRegI("V_TEMP1", RSMap)) else (ifMInt ((S ==K S16) orBool (S ==K U16)) then mi(16, getRegI("V_TEMP1", RSMap)) else (ifMInt ((S ==K S32) orBool (S ==K U32)) then (mi(32, getRegI("V_TEMP1", RSMap))) else (undefMInt) ))), 32)) else ( signExtend( (ifMInt ((S ==K S8) orBool (S ==K U8)) then mi(8, getRegI("V_TEMP2", RSMap)) else (ifMInt ((S ==K S16) orBool (S ==K U16)) then mi(16, getRegI("V_TEMP2", RSMap)) else (ifMInt ((S ==K S32) orBool (S ==K U32)) then (mi(32, getRegI("V_TEMP2", RSMap))) else (undefMInt) ))), 32) ) )
         
       ) </regstate>
endmodule
