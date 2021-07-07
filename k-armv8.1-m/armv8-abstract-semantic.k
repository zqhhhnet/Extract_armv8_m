require "armv8-configuration.k"

module ARMV8-ABSTRACT-SEMANTIC
  imports ARMV8-CONFIGURATION
  
  /*@
    Translate register to Regstate keys
  */
  
  rule convToRegKeys(R) =>  convToRegKeysHelper(convSubRegsToRegs(R))

  rule convToRegKeysHelper(r0)   => "R0"
  rule convToRegKeysHelper(r1)   => "R1"
  rule convToRegKeysHelper(r2)   => "R2"
  rule convToRegKeysHelper(r3)   => "R3"
  rule convToRegKeysHelper(r4)   => "R4"
  rule convToRegKeysHelper(r5)   => "R5"
  rule convToRegKeysHelper(r6)   => "R6"
  rule convToRegKeysHelper(r7)   => "R7"
  rule convToRegKeysHelper(r8)    => "R8"
  rule convToRegKeysHelper(r9)    => "R9"
  rule convToRegKeysHelper(r10)   => "R10"
  rule convToRegKeysHelper(r11)   => "R11"
  rule convToRegKeysHelper(r12)   => "R12"
  rule convToRegKeysHelper(r13)   => "R13"
  rule convToRegKeysHelper(r14)   => "R14"
  rule convToRegKeysHelper(r15)   => "R15"
  rule convToRegKeysHelper(q0)  => "Q0"
  rule convToRegKeysHelper(q1)  => "Q1"
  rule convToRegKeysHelper(q2)  => "Q2"
  rule convToRegKeysHelper(q3)  => "Q3"
  rule convToRegKeysHelper(q4)  => "Q4"
  rule convToRegKeysHelper(q5)  => "Q5"
  rule convToRegKeysHelper(q6)  => "Q6"
  rule convToRegKeysHelper(q7)  => "Q7"
  
  rule convToRegKeysHelper(result) => "RESULT"
  
  /*
  rule convToRegKeysHelper(control)  => "CONTROL"
  rule convToRegKeysHelper(control_s)  => "CONTROL_S"
  rule convToRegKeysHelper(control_ns)  => "CONTROL_NS"
  rule convToRegKeysHelper(cpacr)  => "CPACR"
  rule convToRegKeysHelper(cpacr_s)  => "CPACR_S"
  rule convToRegKeysHelper(cpacr_ns)  => "CPACR_NS"
  rule convToRegKeysHelper(nsacr)  => "NSACR"
  rule convToRegKeysHelper(cppwr)  => "CPPWR"
  rule convToRegKeysHelper(cppwr_s)  => "CPPWR_S"
  rule convToRegKeysHelper(cppwr_ns)  => "CPPWR_NS"
  rule convToRegKeysHelper(mvfr1)  => "MVFR1"
  rule convToRegKeysHelper(fpccr)  => "FPCCR"
  rule convToRegKeysHelper(fpccr_s)  => "FPCCR_S"
  rule convToRegKeysHelper(fpccr_ns)  => "FPCCR_NS"
  rule convToRegKeysHelper(vpr)  => "VPR"
  rule convToRegKeysHelper(epsr)  => "EPSR"
   */
   
  /*@
    Sub registers to Registers
  */
  
  rule convSubRegsToRegs(result) => result
  
  rule convSubRegsToRegs(s0)  => q0
  rule convSubRegsToRegs(s1)  => q0
  rule convSubRegsToRegs(s2)  => q0
  rule convSubRegsToRegs(s3)  => q0
  
  rule convSubRegsToRegs(s4)  => q1
  rule convSubRegsToRegs(s5)  => q1
  rule convSubRegsToRegs(s6)  => q1
  rule convSubRegsToRegs(s7)  => q1
  
  rule convSubRegsToRegs(s8)  => q2
  rule convSubRegsToRegs(s9)  => q2
  rule convSubRegsToRegs(s10)  => q2
  rule convSubRegsToRegs(s11)  => q2
  
  rule convSubRegsToRegs(s12)  => q3
  rule convSubRegsToRegs(s13)  => q3
  rule convSubRegsToRegs(s14)  => q3
  rule convSubRegsToRegs(s15)  => q3
  
  rule convSubRegsToRegs(s16)  => q4
  rule convSubRegsToRegs(s17)  => q4
  rule convSubRegsToRegs(s18)  => q4
  rule convSubRegsToRegs(s19)  => q4
  
  rule convSubRegsToRegs(s20)  => q5
  rule convSubRegsToRegs(s21)  => q5
  rule convSubRegsToRegs(s22)  => q5
  rule convSubRegsToRegs(s23)  => q5
  
  rule convSubRegsToRegs(s24)  => q6
  rule convSubRegsToRegs(s25)  => q6
  rule convSubRegsToRegs(s26)  => q6
  rule convSubRegsToRegs(s27)  => q6
  
  rule convSubRegsToRegs(s28)  => q7
  rule convSubRegsToRegs(s29)  => q7
  rule convSubRegsToRegs(s30)  => q7
  rule convSubRegsToRegs(s31)  => q7
  
  rule convSubRegsToRegs(d0)  => q0
  rule convSubRegsToRegs(d1)  => q0
  
  rule convSubRegsToRegs(d2)  => q1
  rule convSubRegsToRegs(d3)  => q1
  
  rule convSubRegsToRegs(d4)  => q2
  rule convSubRegsToRegs(d5)  => q2
  
  rule convSubRegsToRegs(d6)  => q3
  rule convSubRegsToRegs(d7)  => q3
  
  rule convSubRegsToRegs(d8)  => q4
  rule convSubRegsToRegs(d9)  => q4
  
  rule convSubRegsToRegs(d10)  => q5
  rule convSubRegsToRegs(d11)  => q5
  
  rule convSubRegsToRegs(d12)  => q6
  rule convSubRegsToRegs(d13)  => q6
  
  rule convSubRegsToRegs(d14)  => q7
  rule convSubRegsToRegs(d15)  => q7
  
  rule convSubRegsToRegs(q0) => q0
  rule convSubRegsToRegs(q1) => q1
  rule convSubRegsToRegs(q2) => q2
  rule convSubRegsToRegs(q3) => q3
  rule convSubRegsToRegs(q4) => q4
  rule convSubRegsToRegs(q5) => q5
  rule convSubRegsToRegs(q6) => q6
  rule convSubRegsToRegs(q7) => q7
  
  rule convSubRegsToRegs(r0) => r0
  rule convSubRegsToRegs(r1) => r1
  rule convSubRegsToRegs(r2) => r2
  rule convSubRegsToRegs(r3) => r3
  rule convSubRegsToRegs(r4) => r4
  rule convSubRegsToRegs(r5) => r5
  rule convSubRegsToRegs(r6) => r6
  rule convSubRegsToRegs(r7) => r7
  rule convSubRegsToRegs(r8) => r8
  rule convSubRegsToRegs(r9) => r9
  rule convSubRegsToRegs(r10) => r10
  rule convSubRegsToRegs(r11) => r11
  rule convSubRegsToRegs(r12) => r12
  rule convSubRegsToRegs(r13) => r13
  rule convSubRegsToRegs(r14) => r14
  rule convSubRegsToRegs(r15) => r15
  
  /*
  rule convSubRegsToRegs(control) => control
  rule convSubRegsToRegs(control_s) => control_s
  rule convSubRegsToRegs(control_ns) => control_ns
  rule convSubRegsToRegs(cpacr) => cpacr
  rule convSubRegsToRegs(cpacr_s) => cpacr_s
  rule convSubRegsToRegs(cpacr_ns) => cpacr_ns
  rule convSubRegsToRegs(nsacr) => nsacr
  rule convSubRegsToRegs(cppwr) => cppwr
  rule convSubRegsToRegs(cppwr_s) => cppwr_s
  rule convSubRegsToRegs(cppwr_ns) => cppwr_ns
  rule convSubRegsToRegs(mvfr1) => mvfr1
  rule convSubRegsToRegs(fpccr) => fpccr
  rule convSubRegsToRegs(fpccr_ns) => fpccr_ns
  rule convSubRegsToRegs(fpccr_s) => fpccr_s
  rule convSubRegsToRegs(vpr) => vpr
  rule convSubRegsToRegs(epsr) => epsr
  */
  
  /*@
    Getting the registers values according to the register variants.
  */
  rule getRegisterValue(R:R32,  RSMap)  =>  extractMask({RSMap[convToRegKeys(R)]}:>MInt, 32, 0)
  rule getRegisterValue(R:Q128, RSMap)  =>  extractMask({RSMap[convToRegKeys(R)]}:>MInt, 128, 0)
  // rule getRegisterValue(R:MRegs, RSMap) => extractMask({RSMap[convToRegKeys(R)]}:>MInt, 32, 0)
  rule getRegisterValue(R:VirtualReg, RSMap) => extractMask({RSMap[convToRegKeys(R)]}:>MInt, 32, 0)
  
  rule getParentValue(R:Register, RSMap) => getRegisterValue(convSubRegsToRegs(R), RSMap)
  
  /*@
    handleImmediateWithSignExtend(Imm, M, N): Compute a MInt corresponding
    to the Imm value of width M and sign extend to N.
  */

  // Imm could be an Int
  rule handleImmediateWithSignExtend((# I:Int):Imm, M:Int, N:Int) => signExtend(mi(M,I), N)
  
  // Or a HexConstant: For hexconstants ike 0x800, we have to provide the substr 800
  // as an argument to  String2Base                                          
  syntax String ::= HexConstant2String ( HexInt )    [function, hook(STRING.token2string)]
  //rule handleImmediateWithSignExtend($0x H:HexConstant, M:Int, N:Int) =>
  //  signExtend(mi(M, String2Base(HexConstant2String(H), 16)), N)
  rule handleImmediateWithSignExtend((H:HexInt):Imm, M:Int, N:Int) =>
    signExtend(mi(M, String2Base(substrString(HexConstant2String(H), 3, lengthString(HexConstant2String(H))), 16)), N)
    
  /*@ 
    Check if two registers are the same
  */  
  rule sameRegisters(R1:Register, R2:Register) =>  convToRegKeys(R1) ==String  convToRegKeys(R2)
  rule sameRegisters(R1:Register, S2:String)   =>  convToRegKeys(R1) ==String  S2
  
  /*@ 
    Update Register's value at arbitrary position.
  */  
  rule <k> setRegisterBitsAtPositon(MInew, R, P) => . ...</k>
    <regstate>... convToRegKeys(R) |-> ( MIold => plugInMask(MIold, MInew, P)) ...</regstate>
  
  /*@ 
    getRegisterBitsAtPositon(R, P, N) 
      Returns N bits of input register  R starting at 
    position P.
  */  
  rule getRegisterBitsAtPositon(R, N, P, RSMap) => extractMask(getRegisterValue(R, RSMap), N, P) 
  
  /*@ 
    Get Register size based on the variant used.
  */  
  rule getRegisterSize(R:R32)  => 32
  rule getRegisterSize(R:Q128)  => 128
  
  /*
  rule defaultRegs(S:Label) => setdRegs( S )
  
  rule <k> 
         setDefaultRegs(S:Label) => defaultRegs(S)
       </k>
  */
  
  rule getReg(RName, RSMap) => {RSMap[RName]}:>MInt
  
endmodule
