start:
  //VMOV q7, #21390950401
  //VMOV q4, #2143289344
  //MOV r5, #2063597761
  //VMAXAV.S32 r5, q3
  //VMAXA.S32 q5, q3
  //VMAXNM.F16 q4, q7
  //MOV d0, #9223372036854775809
  //MOV d2, #9221120237041090559 //SNaN  //#9223372036854775807 QNaN     //#8935141660703064063 normal
  //VMAXNM.F64 d3, d0, d2
  //VMOV q0, #4294967295 //#4294942719  //#4294967295 //#9221120237041090559
  //VMOV q1, #9223372036854775809
  //MOV r3, #4294967295
  //VMAXAV.S32 r3, q1
  
  //VMOV q0, #158461160842489849988808179726  // 0x0 0x2 0x4 0x6 0x8 0xA 0xC 0xE, 16b per element
  //VMOV q1, #340246020288323119460258049527564009464 // 0x-8 0x-8 0x-8 0x-8 0x-8 0x-8 0x-8 0x-8
  //VMINA.S16 q0, q1 // 0x8 0x8 0x8 0x8 0x8 0xA 0xC 0xE
  //MOV d0, #9223372036854775809
  //MOV d1, #9221120237041090559
  //VMAXNM.F64 d2, d0, d1
  // MOV r0
  //MOV d0, #9223372036854775807
  //MOV d1, #9223372036854775807  // #9221120237041090559
  //VMAXNM.F64 d2, d0, d1
  VMOV q0, #79230580421244924994404089863000
  VMOV q1, #41538929472669868031141181829283841000
  VMLAV.S16 r0, q0, q1
  VMOV q0, #6975199584193399393683324966251779475231
  VMOV q1, #4334273238700295024477116501114680722049
  VMLAV.S16 r0, q0, q1
end
