require "armv8-semantics.k"

module TEST-SPEC-VADD-I16-QQ

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
         code ( memloc(mi(32, 0)) |-> storedInstr ( VADD . I16 q2 , q0 , q1 , .Operands ) )
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
         "Q1"  |-> concatenateMInt(mi(16, A1), concatenateMInt(mi(16, B1), concatenateMInt(mi(16, C1), concatenateMInt(mi(16, D1), concatenateMInt(mi(16, E1), concatenateMInt(mi(16, F1), concatenateMInt(mi(16, G1), mi(16, H1))))))))
         "Q2"  |-> ( mi(128, _:Int) => concatenateMInt(
                                            concatenateMInt(
                                                addMInt(mi(16, A0), mi(16, A1)),
                                                addMInt(mi(16, B0), mi(16, B1))
                                            ),
                                            concatenateMInt(
                                                concatenateMInt(
                                                    addMInt(mi(16, C0), mi(16, C1)),
                                                    addMInt(mi(16, D0), mi(16, D1))
                                                ),
                                                concatenateMInt(
                                                    concatenateMInt(
                                                        addMInt(mi(16, E0), mi(16, E1)),
                                                        addMInt(mi(16, F0), mi(16, F1))
                                                    ), 
                                                    concatenateMInt(
                                                        addMInt(mi(16, G0), mi(16, G1)),
                                                        addMInt(mi(16, H0), mi(16, H1))
                                                    )
                                                )
                                            )
                                        )
         )
         "S0" |-> concatenateMInt(mi(16, G0), mi(16, H0))
         "S1" |-> concatenateMInt(mi(16, E0), mi(16, F0))
         "S2" |-> concatenateMInt(mi(16, C0), mi(16, D0))
         "S3" |-> concatenateMInt(mi(16, A0), mi(16, B0))
         "S4" |-> concatenateMInt(mi(16, G1), mi(16, H1))
         "S5" |-> concatenateMInt(mi(16, E1), mi(16, F1))
         "S6" |-> concatenateMInt(mi(16, C1), mi(16, D1))
         "S7" |-> concatenateMInt(mi(16, A1), mi(16, B1))

         "S8" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, G0), mi(16, G1)),
                                            addMInt(mi(16, H0), mi(16, H1))
                                        )
                                    ) then
                                        concatenateMInt(
                                            extractMInt(addMInt(mi(16, G0), mi(16, G1)), 0, 8),
                                            concatenateMInt(
                                                addMInt(extractMInt(mi(16, G0), 8, 16), extractMInt(mi(16, G1), 8, 16)),
                                                concatenateMInt(
                                                    extractMInt(addMInt(mi(16, H0), mi(16, H1)), 0, 8),
                                                    addMInt(extractMInt(mi(16, H0), 8, 16), extractMInt(mi(16, H1), 8, 16))
                                                )
                                            )
                                        )
                                    else 
                                        undefMInt32 )
         "S9" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, E0), mi(16, E1)),
                                            addMInt(mi(16, F0), mi(16, F1))
                                        )
                                    ) then 
                                        concatenateMInt(
                                            extractMInt(addMInt(mi(16, E0), mi(16, E1)), 0, 8),
                                            concatenateMInt(
                                                addMInt(extractMInt(mi(16, E0), 8, 16), extractMInt(mi(16, E1), 8, 16)),
                                                concatenateMInt(
                                                    extractMInt(addMInt(mi(16, F0), mi(16, F1)), 0, 8),
                                                    addMInt(extractMInt(mi(16, F0), 8, 16), extractMInt(mi(16, F1), 8, 16))
                                                )
                                            )
                                        )
                                    else 
                                        undefMInt32 )
         "S10" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, C0), mi(16, C1)),
                                            addMInt(mi(16, D0), mi(16, D1))
                                        )
                                    ) then
                                        concatenateMInt(
                                            extractMInt(addMInt(mi(16, C0), mi(16, C1)), 0, 8),
                                            concatenateMInt(
                                                addMInt(extractMInt(mi(16, C0), 8, 16), extractMInt(mi(16, C1), 8, 16)),
                                                concatenateMInt(
                                                    extractMInt(addMInt(mi(16, D0), mi(16, D1)), 0, 8),
                                                    addMInt(extractMInt(mi(16, D0), 8, 16), extractMInt(mi(16, D1), 8, 16))
                                                )
                                            )
                                        )
                                    else 
                                        undefMInt32 )
         "S11" |-> (mi(32, _:Int) => ifMInt notBool IsUndef (
                                        concatenateMInt(
                                            addMInt(mi(16, A0), mi(16, A1)),
                                            addMInt(mi(16, B0), mi(16, B1))
                                        )
                                    ) then 
                                        concatenateMInt(
                                            extractMInt(addMInt(mi(16, A0), mi(16, A1)), 0, 8),
                                            concatenateMInt(
                                                addMInt(extractMInt(mi(16, A0), 8, 16), extractMInt(mi(16, A1), 8, 16)),
                                                concatenateMInt(
                                                    extractMInt(addMInt(mi(16, B0), mi(16, B1)), 0, 8),
                                                    addMInt(extractMInt(mi(16, B0), 8, 16), extractMInt(mi(16, B1), 8, 16))
                                                )
                                            )
                                        )
                                    else 
                                        undefMInt32 )
         "RESULT" |-> ( mi(32, 0) => concatenateMInt(
                                            addMInt(mi(16, A0), mi(16, A1)),
                                            addMInt(mi(16, B0), mi(16, B1))
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
           andBool A1 >=Int 0
           andBool A1 <Int (2 ^Int 16)
           andBool B1 >=Int 0
           andBool B1 <Int (2 ^Int 16)
           andBool C1 >=Int 0
           andBool C1 <Int (2 ^Int 16)
           andBool D1 >=Int 0
           andBool D1 <Int (2 ^Int 16)
           andBool E1 >=Int 0
           andBool E1 <Int (2 ^Int 16)
           andBool F1 >=Int 0
           andBool F1 <Int (2 ^Int 16)
           andBool G1 >=Int 0
           andBool G1 <Int (2 ^Int 16)
           andBool H1 >=Int 0
           andBool H1 <Int (2 ^Int 16)

endmodule
