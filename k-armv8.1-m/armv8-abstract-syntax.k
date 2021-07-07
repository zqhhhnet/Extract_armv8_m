require "armv8-syntax.k"

module ARMV8-ABSTRACT-SYNTAX
  imports MAP
  imports MINT
  imports STRING
  imports ARMV8-SYNTAX-SORTS
  
  syntax CodeInMemory ::= code(/*MInt -> storeInstr(Instruction)*/ Map)
  
  syntax AbsCommand ::= storedInstr(Instruction)
  syntax AbsCommand ::= execinstr1Beat(Instruction)
                      | execinstr2Beat(Instruction)
                      | execinstr3Beat(Instruction)
                      | execinstr4Beat(Instruction)
                      | execinstr(Instruction)
  syntax AbsCommand ::= setDefaultRegs(Opcode)
  syntax AbsCommand ::= beat1Result(Instruction)
                      | beat2Result(Instruction)
                      | beat3Result(Instruction)
                      | beat4Result(Instruction)
  
  syntax MInt ::= getReg(String, Map) [function]
  
  syntax KItem ::= "scan" [token]
                 | "loadBegin"
                 | "registersMessage" [token]
                 
  /*
  syntax KItem ::= setDefaultRegs(Label) [function]
                 | defaultRegs(Label) [strict]
  
  syntax SetdRegs ::= setdRegs ( Label )
  */
  
  /*@
    Sub registers to Registers
  */
  syntax Register ::= convSubRegsToRegs(Register) [function]
  
  /*@
    Translate register to Regstate keys
  */
  syntax String ::= convToRegKeys(Register) [function]
                  | convToRegKeysHelper(Register) [function]
  
  syntax KItem ::= setRegisterValue(KItem, Register) [strict(1)]
  
  syntax KResult ::= MInt
  
  /*@
    Setting the Parent register's values.
      Ex. setParentValue(MI, s0) -> set MI to lowest 32bit of q0
  */  
  syntax MInt  ::= setParentValue(KItem, Register) [strict(1)]
  
  /*@
    Getting the registers values.
      Ex. getRegisterValue(s0) -> 0-31 bits of q0
      Ex. getRegisterValue(s1) -> 32-63 bits of q0
      Ex. getRegisterValue(s2)-> 64-95 bits of q0
      Ex. getRegisterValue(s3)-> lower 96-127 bits of q0
      Ex. getRegisterValue(q0)-> lower 128 bits of q0
  */  
  syntax MInt  ::= getRegisterValue(Register, Map) [function]
  
  /*@
    Getting the Parent register's values.
      Ex. getParentValue(s0) -> 128 bits of q0
      Ex. getParentValue(s1) -> 128 bits of q0
      Ex. getParentValue(s2)-> 128 bits of q0
      Ex. getParentValue(s3)-> 128 bits of q0
      Ex. getParentValue(r0)-> 32 bits of r0
  */  
  syntax MInt  ::= getParentValue(Register, Map) [function]
  
  /*@
    handleImmediateWithSignExtend(Imm, M, N): Compute a MInt corresponding
    to the Imm value of width M and Sign Extend to bitwidth 
    N.
  */
  syntax MInt ::=  handleImmediateWithSignExtend(Imm, Int, Int) [function]
  
  /*@ 
    Check if two registers are the same
  */  
  syntax Bool ::= sameRegisters(Register, Register) [function, klabel(registerargs)]
  syntax Bool ::= sameRegisters(Register, String) [function, klabel(nonregisterargs)]
  
  /*@ 
    setRegisterBitsAtPositon(MI, R, P) 
      Update bitwidthMInt(MI) bits of input register  R starting at 
    position P.
  */  
  syntax MInt ::= setRegisterBitsAtPositon(MInt, Register, Int)
  
  /*@ 
    getRegisterBitsAtPositon(R, P, N) 
      Returns N bits of input register  R starting at 
    position P.
  */  
  syntax MInt ::= getRegisterBitsAtPositon(Register, Int, Int, Map) [function]
  
  /*@ 
    Get Register size based on the variant used.
  */  
  syntax Int ::= getRegisterSize(Register) [function]
  
  
endmodule
