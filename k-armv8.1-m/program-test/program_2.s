// set each element value to the vector register,
// and begin the maxpool and fully-connected operation.

start:
  MOV r0, #1
  VMOV.$8 q0[0], r0
  MOV r0, #2
  VMOV.$8 q0[1], r0
  MOV r0, #3
  VMOV.$8 q0[2], r0
  MOV r0, #4
  VMOV.$8 q0[3], r0
  MOV r0, #5
  VMOV.$8 q0[4], r0
  MOV r0, #6
  VMOV.$8 q0[5], r0
  MOV r0, #7
  VMOV.$8 q0[6], r0
  MOV r0, #8
  VMOV.$8 q0[7], r0
  MOV r0, #9
  VMOV.$8 q0[8], r0
  MOV r0, #10
  VMOV.$8 q0[9], r0
  MOV r0, #11
  VMOV.$8 q0[10], r0
  MOV r0, #12
  VMOV.$8 q0[11], r0
  MOV r0, #13
  VMOV.$8 q0[12], r0
  MOV r0, #14
  VMOV.$8 q0[13], r0
  MOV r0, #15
  VMOV.$8 q0[14], r0
  MOV r0, #16
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[0], r1
  
  MOV r0, #29
  VMOV.$8 q0[0], r0
  MOV r0, #28
  VMOV.$8 q0[1], r0
  MOV r0, #30
  VMOV.$8 q0[2], r0
  MOV r0, #32
  VMOV.$8 q0[3], r0
  MOV r0, #17
  VMOV.$8 q0[4], r0
  MOV r0, #18
  VMOV.$8 q0[5], r0
  MOV r0, #19
  VMOV.$8 q0[6], r0
  MOV r0, #20
  VMOV.$8 q0[7], r0
  MOV r0, #26
  VMOV.$8 q0[8], r0
  MOV r0, #27
  VMOV.$8 q0[9], r0
  MOV r0, #25
  VMOV.$8 q0[10], r0
  MOV r0, #23
  VMOV.$8 q0[11], r0
  MOV r0, #24
  VMOV.$8 q0[12], r0
  MOV r0, #22
  VMOV.$8 q0[13], r0
  MOV r0, #21
  VMOV.$8 q0[14], r0
  MOV r0, #31
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[1], r1
  
  MOV r0, #255
  VMOV.$8 q0[0], r0
  MOV r0, #254
  VMOV.$8 q0[1], r0
  MOV r0, #0
  VMOV.$8 q0[2], r0
  MOV r0, #253
  VMOV.$8 q0[3], r0
  MOV r0, #4
  VMOV.$8 q0[4], r0
  MOV r0, #6
  VMOV.$8 q0[5], r0
  MOV r0, #7
  VMOV.$8 q0[6], r0
  MOV r0, #8
  VMOV.$8 q0[7], r0
  MOV r0, #9
  VMOV.$8 q0[8], r0
  MOV r0, #10
  VMOV.$8 q0[9], r0
  MOV r0, #12
  VMOV.$8 q0[10], r0
  MOV r0, #14
  VMOV.$8 q0[11], r0
  MOV r0, #252
  VMOV.$8 q0[12], r0
  MOV r0, #250
  VMOV.$8 q0[13], r0
  MOV r0, #251
  VMOV.$8 q0[14], r0
  MOV r0, #11
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[2], r1
  
  MOV r0, #43
  VMOV.$8 q0[0], r0
  MOV r0, #62
  VMOV.$8 q0[1], r0
  MOV r0, #11
  VMOV.$8 q0[2], r0
  MOV r0, #19
  VMOV.$8 q0[3], r0
  MOV r0, #28
  VMOV.$8 q0[4], r0
  MOV r0, #30
  VMOV.$8 q0[5], r0
  MOV r0, #31
  VMOV.$8 q0[6], r0
  MOV r0, #40
  VMOV.$8 q0[7], r0
  MOV r0, #56
  VMOV.$8 q0[8], r0
  MOV r0, #57
  VMOV.$8 q0[9], r0
  MOV r0, #1
  VMOV.$8 q0[10], r0
  MOV r0, #10
  VMOV.$8 q0[11], r0
  MOV r0, #12
  VMOV.$8 q0[12], r0
  MOV r0, #14
  VMOV.$8 q0[13], r0
  MOV r0, #16
  VMOV.$8 q0[14], r0
  MOV r0, #18
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[3], r1
  
  MOV r0, #100
  VMOV.$8 q0[0], r0
  MOV r0, #9
  VMOV.$8 q0[1], r0
  MOV r0, #8
  VMOV.$8 q0[2], r0
  MOV r0, #7
  VMOV.$8 q0[3], r0
  MOV r0, #6
  VMOV.$8 q0[4], r0
  MOV r0, #5
  VMOV.$8 q0[5], r0
  MOV r0, #4
  VMOV.$8 q0[6], r0
  MOV r0, #3
  VMOV.$8 q0[7], r0
  MOV r0, #20
  VMOV.$8 q0[8], r0
  MOV r0, #21
  VMOV.$8 q0[9], r0
  MOV r0, #22
  VMOV.$8 q0[10], r0
  MOV r0, #24
  VMOV.$8 q0[11], r0
  MOV r0, #25
  VMOV.$8 q0[12], r0
  MOV r0, #26
  VMOV.$8 q0[13], r0
  MOV r0, #28
  VMOV.$8 q0[14], r0
  MOV r0, #29
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[4], r1
  
  MOV r0, #11
  VMOV.$8 q0[0], r0
  MOV r0, #17
  VMOV.$8 q0[1], r0
  MOV r0, #19
  VMOV.$8 q0[2], r0
  MOV r0, #21
  VMOV.$8 q0[3], r0
  MOV r0, #22
  VMOV.$8 q0[4], r0
  MOV r0, #24
  VMOV.$8 q0[5], r0
  MOV r0, #26
  VMOV.$8 q0[6], r0
  MOV r0, #30
  VMOV.$8 q0[7], r0
  MOV r0, #35
  VMOV.$8 q0[8], r0
  MOV r0, #37
  VMOV.$8 q0[9], r0
  MOV r0, #39
  VMOV.$8 q0[10], r0
  MOV r0, #46
  VMOV.$8 q0[11], r0
  MOV r0, #21
  VMOV.$8 q0[12], r0
  MOV r0, #25
  VMOV.$8 q0[13], r0
  MOV r0, #27
  VMOV.$8 q0[14], r0
  MOV r0, #29
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[5], r1
  
  MOV r0, #101
  VMOV.$8 q0[0], r0
  MOV r0, #121
  VMOV.$8 q0[1], r0
  MOV r0, #120
  VMOV.$8 q0[2], r0
  MOV r0, #113
  VMOV.$8 q0[3], r0
  MOV r0, #27
  VMOV.$8 q0[4], r0
  MOV r0, #28
  VMOV.$8 q0[5], r0
  MOV r0, #26
  VMOV.$8 q0[6], r0
  MOV r0, #39
  VMOV.$8 q0[7], r0
  MOV r0, #252
  VMOV.$8 q0[8], r0
  MOV r0, #234
  VMOV.$8 q0[9], r0
  MOV r0, #226
  VMOV.$8 q0[10], r0
  MOV r0, #186
  VMOV.$8 q0[11], r0
  MOV r0, #91
  VMOV.$8 q0[12], r0
  MOV r0, #92
  VMOV.$8 q0[13], r0
  MOV r0, #94
  VMOV.$8 q0[14], r0
  MOV r0, #96
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[6], r1
  
  MOV r0, #22
  VMOV.$8 q0[0], r0
  MOV r0, #24
  VMOV.$8 q0[1], r0
  MOV r0, #29
  VMOV.$8 q0[2], r0
  MOV r0, #28
  VMOV.$8 q0[3], r0
  MOV r0, #70
  VMOV.$8 q0[4], r0
  MOV r0, #72
  VMOV.$8 q0[5], r0
  MOV r0, #74
  VMOV.$8 q0[6], r0
  MOV r0, #73
  VMOV.$8 q0[7], r0
  MOV r0, #46
  VMOV.$8 q0[8], r0
  MOV r0, #45
  VMOV.$8 q0[9], r0
  MOV r0, #32
  VMOV.$8 q0[10], r0
  MOV r0, #31
  VMOV.$8 q0[11], r0
  MOV r0, #90
  VMOV.$8 q0[12], r0
  MOV r0, #92
  VMOV.$8 q0[13], r0
  MOV r0, #96
  VMOV.$8 q0[14], r0
  MOV r0, #98
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[7], r1
  
  MOV r0, #9
  VMOV.$8 q0[0], r0
  MOV r0, #10
  VMOV.$8 q0[1], r0
  MOV r0, #12
  VMOV.$8 q0[2], r0
  MOV r0, #14
  VMOV.$8 q0[3], r0
  MOV r0, #15
  VMOV.$8 q0[4], r0
  MOV r0, #16
  VMOV.$8 q0[5], r0
  MOV r0, #22
  VMOV.$8 q0[6], r0
  MOV r0, #27
  VMOV.$8 q0[7], r0
  MOV r0, #9
  VMOV.$8 q0[8], r0
  MOV r0, #8
  VMOV.$8 q0[9], r0
  MOV r0, #7
  VMOV.$8 q0[10], r0
  MOV r0, #6
  VMOV.$8 q0[11], r0
  MOV r0, #5
  VMOV.$8 q0[12], r0
  MOV r0, #4
  VMOV.$8 q0[13], r0
  MOV r0, #3
  VMOV.$8 q0[14], r0
  MOV r0, #2
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[8], r1
  
  MOV r0, #1
  VMOV.$8 q0[0], r0
  MOV r0, #2
  VMOV.$8 q0[1], r0
  MOV r0, #3
  VMOV.$8 q0[2], r0
  MOV r0, #4
  VMOV.$8 q0[3], r0
  MOV r0, #5
  VMOV.$8 q0[4], r0
  MOV r0, #6
  VMOV.$8 q0[5], r0
  MOV r0, #7
  VMOV.$8 q0[6], r0
  MOV r0, #8
  VMOV.$8 q0[7], r0
  MOV r0, #9
  VMOV.$8 q0[8], r0
  MOV r0, #10
  VMOV.$8 q0[9], r0
  MOV r0, #11
  VMOV.$8 q0[10], r0
  MOV r0, #12
  VMOV.$8 q0[11], r0
  MOV r0, #13
  VMOV.$8 q0[12], r0
  MOV r0, #14
  VMOV.$8 q0[13], r0
  MOV r0, #15
  VMOV.$8 q0[14], r0
  MOV r0, #16
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[9], r1
  
  MOV r0, #255
  VMOV.$8 q0[0], r0
  MOV r0, #254
  VMOV.$8 q0[1], r0
  MOV r0, #253
  VMOV.$8 q0[2], r0
  MOV r0, #252
  VMOV.$8 q0[3], r0
  MOV r0, #251
  VMOV.$8 q0[4], r0
  MOV r0, #250
  VMOV.$8 q0[5], r0
  MOV r0, #249
  VMOV.$8 q0[6], r0
  MOV r0, #248
  VMOV.$8 q0[7], r0
  MOV r0, #247
  VMOV.$8 q0[8], r0
  MOV r0, #246
  VMOV.$8 q0[9], r0
  MOV r0, #245
  VMOV.$8 q0[10], r0
  MOV r0, #244
  VMOV.$8 q0[11], r0
  MOV r0, #243
  VMOV.$8 q0[12], r0
  MOV r0, #242
  VMOV.$8 q0[13], r0
  MOV r0, #241
  VMOV.$8 q0[14], r0
  MOV r0, #240
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[10], r1
  
  MOV r0, #7
  VMOV.$8 q0[0], r0
  MOV r0, #6
  VMOV.$8 q0[1], r0
  MOV r0, #5
  VMOV.$8 q0[2], r0
  MOV r0, #4
  VMOV.$8 q0[3], r0
  MOV r0, #8
  VMOV.$8 q0[4], r0
  MOV r0, #9
  VMOV.$8 q0[5], r0
  MOV r0, #10
  VMOV.$8 q0[6], r0
  MOV r0, #11
  VMOV.$8 q0[7], r0
  MOV r0, #22
  VMOV.$8 q0[8], r0
  MOV r0, #24
  VMOV.$8 q0[9], r0
  MOV r0, #26
  VMOV.$8 q0[10], r0
  MOV r0, #28
  VMOV.$8 q0[11], r0
  MOV r0, #30
  VMOV.$8 q0[12], r0
  MOV r0, #32
  VMOV.$8 q0[13], r0
  MOV r0, #34
  VMOV.$8 q0[14], r0
  MOV r0, #36
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[11], r1
  
  MOV r0, #3
  VMOV.$8 q0[0], r0
  MOV r0, #4
  VMOV.$8 q0[1], r0
  MOV r0, #5
  VMOV.$8 q0[2], r0
  MOV r0, #6
  VMOV.$8 q0[3], r0
  MOV r0, #22
  VMOV.$8 q0[4], r0
  MOV r0, #24
  VMOV.$8 q0[5], r0
  MOV r0, #26
  VMOV.$8 q0[6], r0
  MOV r0, #27
  VMOV.$8 q0[7], r0
  MOV r0, #4
  VMOV.$8 q0[8], r0
  MOV r0, #7
  VMOV.$8 q0[9], r0
  MOV r0, #9
  VMOV.$8 q0[10], r0
  MOV r0, #11
  VMOV.$8 q0[11], r0
  MOV r0, #2
  VMOV.$8 q0[12], r0
  MOV r0, #4
  VMOV.$8 q0[13], r0
  MOV r0, #6
  VMOV.$8 q0[14], r0
  MOV r0, #8
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[12], r1
  
  MOV r0, #7
  VMOV.$8 q0[0], r0
  MOV r0, #8
  VMOV.$8 q0[1], r0
  MOV r0, #9
  VMOV.$8 q0[2], r0
  MOV r0, #10
  VMOV.$8 q0[3], r0
  MOV r0, #30
  VMOV.$8 q0[4], r0
  MOV r0, #39
  VMOV.$8 q0[5], r0
  MOV r0, #38
  VMOV.$8 q0[6], r0
  MOV r0, #37
  VMOV.$8 q0[7], r0
  MOV r0, #22
  VMOV.$8 q0[8], r0
  MOV r0, #23
  VMOV.$8 q0[9], r0
  MOV r0, #24
  VMOV.$8 q0[10], r0
  MOV r0, #25
  VMOV.$8 q0[11], r0
  MOV r0, #10
  VMOV.$8 q0[12], r0
  MOV r0, #12
  VMOV.$8 q0[13], r0
  MOV r0, #14
  VMOV.$8 q0[14], r0
  MOV r0, #16
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[13], r1
  
  MOV r0, #11
  VMOV.$8 q0[0], r0
  MOV r0, #12
  VMOV.$8 q0[1], r0
  MOV r0, #13
  VMOV.$8 q0[2], r0
  MOV r0, #14
  VMOV.$8 q0[3], r0
  MOV r0, #64
  VMOV.$8 q0[4], r0
  MOV r0, #65
  VMOV.$8 q0[5], r0
  MOV r0, #66
  VMOV.$8 q0[6], r0
  MOV r0, #67
  VMOV.$8 q0[7], r0
  MOV r0, #6
  VMOV.$8 q0[8], r0
  MOV r0, #9
  VMOV.$8 q0[9], r0
  MOV r0, #10
  VMOV.$8 q0[10], r0
  MOV r0, #12
  VMOV.$8 q0[11], r0
  MOV r0, #15
  VMOV.$8 q0[12], r0
  MOV r0, #17
  VMOV.$8 q0[13], r0
  MOV r0, #19
  VMOV.$8 q0[14], r0
  MOV r0, #21
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[14], r1
  
  MOV r0, #15
  VMOV.$8 q0[0], r0
  MOV r0, #16
  VMOV.$8 q0[1], r0
  MOV r0, #17
  VMOV.$8 q0[2], r0
  MOV r0, #18
  VMOV.$8 q0[3], r0
  MOV r0, #30
  VMOV.$8 q0[4], r0
  MOV r0, #31
  VMOV.$8 q0[5], r0
  MOV r0, #32
  VMOV.$8 q0[6], r0
  MOV r0, #33
  VMOV.$8 q0[7], r0
  MOV r0, #7
  VMOV.$8 q0[8], r0
  MOV r0, #6
  VMOV.$8 q0[9], r0
  MOV r0, #5
  VMOV.$8 q0[10], r0
  MOV r0, #4
  VMOV.$8 q0[11], r0
  MOV r0, #3
  VMOV.$8 q0[12], r0
  MOV r0, #4
  VMOV.$8 q0[13], r0
  MOV r0, #255
  VMOV.$8 q0[14], r0
  MOV r0, #254
  VMOV.$8 q0[15], r0
  
  MOV r1, #128
  VMAXV.S8 r1, q0
  VMOV.$8 q1[15], r1
  
  MOV r0, #255
  VMOV.$8 q2[15], r0
  MOV r0, #2
  VMOV.$8 q2[14], r0
  MOV r0, #253
  VMOV.$8 q2[13], r0
  MOV r0, #4
  VMOV.$8 q2[12], r0
  MOV r0, #251
  VMOV.$8 q2[11], r0
  MOV r0, #6
  VMOV.$8 q2[10], r0
  MOV r0, #249
  VMOV.$8 q2[9], r0
  MOV r0, #8
  VMOV.$8 q2[8], r0
  MOV r0, #9
  VMOV.$8 q2[7], r0
  MOV r0, #246
  VMOV.$8 q2[6], r0
  MOV r0, #245
  VMOV.$8 q2[5], r0
  MOV r0, #12
  VMOV.$8 q2[4], r0
  MOV r0, #13
  VMOV.$8 q2[3], r0
  MOV r0, #242
  VMOV.$8 q2[2], r0
  MOV r0, #15
  VMOV.$8 q2[1], r0
  MOV r0, #0
  VMOV.$8 q2[0], r0
  
  MOV r2, #0
  VMLAV.S8 r2, q1, q2
  
  MOV r0, #254
  VMOV.$8 q3[15], r0
  MOV r0, #3
  VMOV.$8 q3[14], r0
  MOV r0, #4
  VMOV.$8 q3[13], r0
  MOV r0, #251
  VMOV.$8 q3[12], r0
  MOV r0, #6
  VMOV.$8 q3[11], r0
  MOV r0, #249
  VMOV.$8 q3[10], r0
  MOV r0, #8
  VMOV.$8 q3[9], r0
  MOV r0, #247
  VMOV.$8 q3[8], r0
  MOV r0, #10
  VMOV.$8 q3[7], r0
  MOV r0, #245
  VMOV.$8 q3[6], r0
  MOV r0, #12
  VMOV.$8 q3[5], r0
  MOV r0, #13
  VMOV.$8 q3[4], r0
  MOV r0, #14
  VMOV.$8 q3[3], r0
  MOV r0, #15
  VMOV.$8 q3[2], r0
  MOV r0, #240
  VMOV.$8 q3[1], r0
  MOV r0, #239
  VMOV.$8 q3[0], r0
  
  MOV r3, #0
  VMLAV.S8 r3, q1, q3
  
  MOV r0, #1
  VMOV.$8 q4[15], r0
  MOV r0, #1
  VMOV.$8 q4[14], r0
  MOV r0, #2
  VMOV.$8 q4[13], r0
  MOV r0, #4
  VMOV.$8 q4[12], r0
  MOV r0, #3
  VMOV.$8 q4[11], r0
  MOV r0, #5
  VMOV.$8 q4[10], r0
  MOV r0, #7
  VMOV.$8 q4[9], r0
  MOV r0, #9
  VMOV.$8 q4[8], r0
  MOV r0, #246
  VMOV.$8 q4[7], r0
  MOV r0, #245
  VMOV.$8 q4[6], r0
  MOV r0, #12
  VMOV.$8 q4[5], r0
  MOV r0, #13
  VMOV.$8 q4[4], r0
  MOV r0, #242
  VMOV.$8 q4[3], r0
  MOV r0, #15
  VMOV.$8 q4[2], r0
  MOV r0, #6
  VMOV.$8 q4[1], r0
  MOV r0, #7
  VMOV.$8 q4[0], r0
  
  MOV r4, #0
  VMLAV.S8 r4, q1, q4
  
  MOV r0, #3
  VMOV.$8 q5[15], r0
  MOV r0, #4
  VMOV.$8 q5[14], r0
  MOV r0, #5
  VMOV.$8 q5[13], r0
  MOV r0, #255
  VMOV.$8 q5[12], r0
  MOV r0, #254
  VMOV.$8 q5[11], r0
  MOV r0, #253
  VMOV.$8 q5[10], r0
  MOV r0, #252
  VMOV.$8 q5[9], r0
  MOV r0, #251
  VMOV.$8 q5[8], r0
  MOV r0, #250
  VMOV.$8 q5[7], r0
  MOV r0, #7
  VMOV.$8 q5[6], r0
  MOV r0, #8
  VMOV.$8 q5[5], r0
  MOV r0, #9
  VMOV.$8 q5[4], r0
  MOV r0, #10
  VMOV.$8 q5[3], r0
  MOV r0, #11
  VMOV.$8 q5[2], r0
  MOV r0, #12
  VMOV.$8 q5[1], r0
  MOV r0, #255
  VMOV.$8 q5[0], r0
  
  MOV r5, #0
  VMLAV.S8 r5, q1, q5
  
end
