require "armv8-loader.k"
require "vmax.k"
require "armv8-abstract-semantic.k"
require "armv8-verification.k"
require "armv8-mint.k"
require "exit.k"
require "vmaxnm.k"
require "vmov.k"

module ARMV8-SEMANTICS
  imports ARMV8-LOADER
  imports ARMV8-ABSTRACT-SEMANTIC
  imports VMAX
  imports ARMV8-VERIFICATION
  imports ARMV8-MINT
  imports EXIT
  imports VMAXNM
  imports VMOV
endmodule
