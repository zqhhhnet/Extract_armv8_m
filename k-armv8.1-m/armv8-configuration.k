require "armv8-syntax.k"
require "armv8-abstract-syntax.k"
require "armv8-mint.k"

module ARMV8-CONFIGURATION
  imports ARMV8-SYNTAX
  imports ARMV8-MINT-SYNTAX
  imports ARMV8-ABSTRACT-SYNTAX
  imports MINT
  
  configuration
    <k>
      // initDefaultRegs ~>
      $PGM:Instructions ~>
      loadBegin ~>
      registersMessage ~>
      scan
    </k>
    
    <begin> .K </begin>
    <currentstate> "text" </currentstate>
    <nextloc> mi(32, 0) </nextloc>
    <functarget> .Map </functarget>
    <instructiontext> code(.Map) </instructiontext>
    
    <regstate> 
      //.Map
      ("R0"		|-> mi(32, 0))
      ("R1"		|-> mi(32, 0))
      ("R2"		|-> mi(32, 0))
      ("R3"		|-> mi(32, 0))
      ("R4"		|-> mi(32, 0))
      ("R5"		|-> mi(32, 0))
      ("R6"		|-> mi(32, 0))
      ("R7"		|-> mi(32, 0))
      ("R8"		|-> mi(32, 0))
      ("R9"		|-> mi(32, 0))
      ("R10"		|-> mi(32, 0))
      ("R11"		|-> mi(32, 0))
      ("R12"		|-> mi(32, 0))
      ("R13"		|-> mi(32, 0))
      ("R14"		|-> mi(32, 0))
      ("R15"		|-> mi(32, 0)) 
      ("Q0"		|-> mi(128, 3598233232840554986))
      ("Q1"		|-> mi(128, 3742348386565061096))
      ("Q2"		|-> mi(128, 0))
      ("Q3"		|-> mi(128, 2445311727982049770))
      ("Q4"		|-> mi(128, 3598233232857332202))
      ("Q5"		|-> mi(128, 0))
      ("Q6"		|-> mi(128, 0))
      ("Q7"		|-> mi(128, 0))
      // virtual regsiter "RESULT", default 32bit 0
      ("RESULT"	|-> mi(32, 0))
      // set default value to regsiters
      ("CONTROL"	|-> mi(32, 0))
      ("CONTROL_S"	|-> mi(32, 0))
      ("CONTROL_NS"	|-> mi(32, 0))
      ("CPACR_S" 	|-> mi(32, 0))
      ("CPACR_NS" 	|-> mi(32, 0))
      ("CPACR" 	|-> mi(32, 0))
      ("NSACR" 	|-> mi(32, 0))
      ("CPPWR_S" 	|-> mi(32, 0))
      ("CPPWR_NS" 	|-> mi(32, 0))
      ("CPPWR"		|-> mi(32, 0))
      ("MVFR1"		|-> mi(32, 0))
      ("EPSR"		|-> mi(32, 0))
      ("FPCCR"		|-> mi(32, 0))
      ("FPCCR_S"	|-> mi(32, 0))
      ("FPCCR_NS"	|-> mi(32, 0))
      ("VPR"		|-> mi(32, 0))
      ("FPSCR"		|-> mi(32, 0))
      
    </regstate>
    
    <regstateseq> .List </regstateseq>
    
endmodule
