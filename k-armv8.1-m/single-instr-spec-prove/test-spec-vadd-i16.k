require "armv8-semantics.k"

module TEST-SPEC-VADD-I16

  imports ARMV8-SEMANTICS

  rule <k>
         scan => End
       </k>
       <begin>
         .K
       </begin>
       <currentstate>
         "text"
       </currentstate>
       <nextloc>
         _:MInt
       </nextloc>
       <functarget>
         start |-> mi(32, 0)
       </functarget>
       <instructiontext>
         code ( memloc(mi(32, 0)) |-> storedInstr ( VADD . I16 q2 , q0 , r1 , .Operands ) )
       </instructiontext>
       <regstate>
         "CONTROL" |-> (mi(32, _:Int) => mi(32, 1))
         "CONTROL_NS" |-> (mi(32, _:Int) => mi(32, 1))
         "CONTROL_S" |-> (mi(32, _:Int) => mi(32, 1))
         "CPACR" |-> (mi(32, _:Int) => mi(32, 3145728))
         "CPACR_NS" |-> (mi(32, _:Int) => mi(32, 3145728))
         "CPACR_S" |-> (mi(32, _:Int) => mi(32, 3145728))
         "CPPWR" |-> (mi(32, _:Int) => mi(32, 0))
         "CPPWR_NS" |-> (mi(32, _:Int) => mi(32, 0))
         "CPPWR_S" |-> (mi(32, _:Int) => mi(32, 0))
         "EPSR" |-> (mi(32, _:Int) => mi(32, 2048))
         "FPCCR" |-> (mi(32, _:Int) => mi(32, 0))
         "FPCCR_NS" |-> (mi(32, _:Int) => mi(32, 0))
         "FPCCR_S" |-> (mi(32, _:Int) => mi(32, 0))
         "MVFR1" |-> (mi(32, _:Int) => mi(32, 256))
         "NSACR" |-> (mi(32, _:Int) => mi(32, 1024))
         "VPR" |-> (mi(32, _:Int) => mi(32, 2048))
         "Q0"  |-> concatenateMInt(mi(16, A0), concatenateMInt(mi(16, B0), concatenateMInt(mi(16, C0), concatenateMInt(mi(16, D0), concatenateMInt(mi(16, E0), concatenateMInt(mi(16, F0), concatenateMInt(mi(16, G0), mi(16, H0))))))))
         "R1"  |-> mi(32, M)
         "Q2"  |-> ( mi(128, _:Int) => concatenateMInt(
                                            concatenateMInt(
                                                addMInt(mi(16, A0), extractMInt(mi(32, M), 16, 32)),
                                                addMInt(mi(16, B0), extractMInt(mi(32, M), 16, 32))
                                            ),
                                            concatenateMInt(
                                                concatenateMInt(
                                                    addMInt(mi(16, C0), extractMInt(mi(32, M), 16, 32)),
                                                    addMInt(mi(16, D0), extractMInt(mi(32, M), 16, 32))
                                                ),
                                                concatenateMInt(
                                                    concatenateMInt(
                                                        addMInt(mi(16, E0), extractMInt(mi(32, M), 16, 32)),
                                                        addMInt(mi(16, F0), extractMInt(mi(32, M), 16, 32))
                                                    ), 
                                                    concatenateMInt(
                                                        addMInt(mi(16, G0), extractMInt(mi(32, M), 16, 32)),
                                                        addMInt(mi(16, H0), extractMInt(mi(32, M), 16, 32))
                                                    )
                                                )
                                            )
                                        )
         )
         "S0" |-> concatenateMInt(mi(16, G0), mi(16, H0))
         "S1" |-> concatenateMInt(mi(16, E0), mi(16, F0))
         "S2" |-> concatenateMInt(mi(16, C0), mi(16, D0))
         "S3" |-> concatenateMInt(mi(16, A0), mi(16, B0))

         "S8" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, G0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, H0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    ) then 
                                        concatenateMInt(
                                            addMInt(mi(16, G0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, H0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    else 
                                        undefMInt32 )
         "S9" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, E0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, F0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    ) then 
                                        concatenateMInt(
                                            addMInt(mi(16, E0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, F0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    else 
                                        undefMInt32 )
         "S10" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, C0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, D0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    ) then 
                                        concatenateMInt(
                                            addMInt(mi(16, C0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, D0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    else 
                                        undefMInt32 )
         "S11" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, A0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, B0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    ) then 
                                        concatenateMInt(
                                            addMInt(mi(16, A0), extractMInt(mi(32, M), 16, 32)),
                                            addMInt(mi(16, B0), extractMInt(mi(32, M), 16, 32))
                                        )
                                    else 
                                        undefMInt32 )
         "RESULT" |-> ( mi(32, 0) => concatenateMInt(
                                        addMInt(mi(16, A0), extractMInt(mi(32, M), 16, 32)),
                                        addMInt(mi(16, B0), extractMInt(mi(32, M), 16, 32))
                                    ) )
         "R15" |-> (memloc(mi(32, 0)) => memloc(mi(32, 1)))
       </regstate>
         requires  A0 >=Int 0
           andBool A0 <Int (2 ^Int 16)
           andBool B0 >=Int 0
           andBool B0 <Int (2 ^Int 16)
           andBool C0 >=Int 0
           andBool C0 <Int (2 ^Int 16)
           andBool D0 >=Int 0
           andBool D0 <Int (2 ^Int 16)
           andBool E0 >=Int 0
           andBool E0 <Int (2 ^Int 16)
           andBool F0 >=Int 0
           andBool F0 <Int (2 ^Int 16)
           andBool G0 >=Int 0
           andBool G0 <Int (2 ^Int 16)
           andBool H0 >=Int 0
           andBool H0 <Int (2 ^Int 16)
           andBool M >=Int 0
           andBool M <Int (2 ^Int 16)

endmodule
