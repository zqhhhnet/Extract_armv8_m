require "armv8-configuration.k"

module ARMV8-MEMINIT-SYNTAX
  
  imports LIST
  
  syntax KItem ::= initMemEnvirnoment(List)

endmodule

module ARMV8-MEMINIT

  imports ARMV8-CONFIGURATION

  rule initMemEnvirnoment(L:List) => allocStackPointer(32, 1024)
  

endmodule
