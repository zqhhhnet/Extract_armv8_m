requires "armv8-configuration.k"

module EXIT
  imports ARMV8-CONFIGURATION
  
  // context execinstr(exit:Opcode . _0:Label .Operands)
  rule <k> setDefaultRegs(exit:Opcode) => . ...</k>
       <regstate> RSMap:Map </regstate>

  rule <k> execinstr (exit:Opcode . _0:Label .Operands) => . ...</k>
       <regstate> RSMap:Map </regstate>
endmodule
