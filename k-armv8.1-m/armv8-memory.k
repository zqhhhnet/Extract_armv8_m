require "armv8-configuration.k"
require "armv8-memory-syntax.k"

module ARMV8-MEMORY

  imports ARMV8-MEMORY-SYNTAX
  imports ARMV8-CONFIGURATION
  imports MEMORY-SORTS
  imports MEMORY-SET-SYNTAX
  imports MAP
  imports SET
  
  /*
   *  the initialization of SP register.
   *  N is the top pointer of stack.
   */
  rule <k> allocStackPointer(A:Int, N:Int) => 
           saveStackPointer(allocLocalMemory(A:Int, N:Int)) ...</k>
       <stackbase>
           stackBaseInfo(.K, .K => mi(A, N -Int 4))
       </stackbase>
         //requires N %Int 4 ==Int 0
  
  /* 
   *  save the SP base address to R12 as IP register
   */
  rule <k> saveStackPointer(L:MemLoc) => . ...</k>
       <stackbase>
           stackBaseInfo(.K => L, MI:MInt)
       </stackbase>
       // R13 is SP register, R12 used for IP register for keep sp base
       <regstate>
         RSMap:Map => updateMap(RSMap,
           "R13" |-> pointer(L, MI)
           "R12" |-> pointer(L, MI)
         )
       </regstate>
  
  /*
   *  allocate local memory map for memory block
   */
  rule <k>
           allocLocalMemory(A:Int, N:Int) => alloc(A, N, 8)
       ...</k>
  
  /*
   *  allocate the block
   */
  rule <k>
           alloc(A:Int, N:Int, S:Int) => memLoc(BlockId, A, N, S, 0) 
       ...</k>
       <nextlocid>
           BlockId:Int => BlockId +Int 1
       </nextlocid>
  
  /*
   *  read from stack memory
   */
  rule <k> loadFromMemory((pointer(L:MemLoc, Addr:MInt)):Pointer, N:Int) 
             => 
           fromMemoryRead(readMem(L, uvalueMInt(Addr) *Int 8, N /Int 8, 8), N)
       </k>
         requires N %Int 8 ==Int 0
  
  /*
   *  load memory data to data list
   */
  rule <k>
           readMem(memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, Vbyte:Int, EleInBits:Int) 
             =>
           readMemValue(memLoc(BID, Al, N, S, I), Off, Vbyte, EleInBits, M)
       </k>
       <stackstate>
           M:Memory
       </stackstate>
       <freedstate>
           F:MemorySet
       </freedstate>
         requires notBool inMemorySet(memLoc(BID, Al, N, S, I), F)	/* check whether freed */
                  andBool ( Off >=Int 0
                  andBool Vbyte >=Int 0
                  andBool Off +Int Vbyte *Int EleInBits <=Int N *Int S)
  
  rule <k>
           readMem(memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, Vbyte:Int, EleInBits:Int)
             =>
           error(OutOfAccessMemoryBound)
       ...</k>
       <freedstate>
           F:MemorySet
       </freedstate>
         requires inMemorySet(memLoc(BID, Al, N, S, I), F)
                  orBool (notBool ( Off >=Int 0
                  andBool Vbyte >=Int 0
                  andBool Off +Int Vbyte *Int EleInBits <=Int N *Int S))
  
  /*
   *  get the value in memory map and set to data list
   */
  rule readMemValue(memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, Vbyte:Int, ESize:Int, mem(M:Map))
             =>
       memList(Vbyte, S, readMemValueHelper(memLoc(BID,Al,N,S,I),
                                            Off /Int S +Int Vbyte -Int 1,
                                            Vbyte, M, .StackList ))
         requires S ==Int ESize
  
  rule readMemValueHelper(_:MemLoc, Off:Int, N:Int, M:Map, D:StackList)
         =>
       D
         requires N ==Int 0
         
  rule readMemValueHelper(memLoc(BID, Al, N, S, I), Off:Int, N:Int, M:Map, D:StackList)
         =>
       readMemValueHelper(memLoc(BID, Al, N, S, I), Off -Int 1, N -Int 1, M,
                          selectMemory(M, memLoc(BID, Al, N, S, I +Int Off)) D)
         requires N >Int 0
  
  /*
   *  get the data of loc in memory map
   */
  rule selectMemory(M:Map, L:MemLoc)
         =>
       {M[L]}:>StackData
         requires L in_keys(M)
  
  rule selectMemory(M:Map, L:MemLoc)
         =>
       getDefaultValue()
         requires notBool L in_keys(M)
         
  rule getDefaultValue() => byte(0, undefMInt8)
  
  /*
   *  from the byte of value in memory to MInt of value
   */
  rule <k>
           fromMemoryRead(memList(_:Int, ESize:Int, D:StackList), N:Int)
             =>
           mintOfLoadValue(byteToMInt(takeStackList(N /Int 8, D)))
       </k>
  
  rule byteToMInt(byte(I:Int, MI:MInt) Rest:StackList)
         =>
       extractMInt(MI, 8 *Int (4 -Int I -Int 1), 8 *Int (4 -Int I))
         requires Rest ==K .StackList
                  andBool I >=Int 0
                  andBool I <=Int 3
  
  rule byteToMInt(byte(I:Int, MI:MInt) Rest:StackList)
         =>
       concatenateMInt(byteToMInt(Rest), extractMInt(MI, 8 *Int (4 -Int I -Int 1), 8 *Int (4 -Int I)))
         requires Rest =/=K .StackList
  
  /*
   *  according to the size of read value, adjust the
   *  sequence of the read data list
   */       
  rule takeStackList(N:Int, D:StackList)
         =>
       takeStackListHelper(N, D, .StackList)
  
  rule takeStackListHelper(N:Int, V:StackData D:StackList, R:StackList)
         =>
       takeStackListHelper(N -Int 1, D, V R)
         requires N >Int 0
  
  rule takeStackListHelper(N:Int, _:StackList, R:StackList)
         =>
       reverseList(R)
         requires N ==Int 0
  
  rule reverseList(D:StackList) => reverseAppendList(D, .StackList)
  
  //  reverse D1 list, and append D2 to the reverse list
  rule reverseAppendList(D1:StackList, D2:StackList) => D2
         requires D1 ==K .StackList
  
  rule reverseAppendList(V:StackData D1:StackList, D2:StackList)
         =>
       reverseAppendList(D1, V D2)
         requires D1 =/=K .StackList
  
  /*
   *   empty memoryset
   */
  syntax MemorySet ::= Set
  
  rule .MemorySet => .Set
  
  rule inMemorySet(L:MemLoc, S:Set) => L in S

  rule addMemorySet(S:Set, L:MemLoc) => SetItem(L) S
  
  /*
   *  store api
   */
  rule <k>
           storeToMemory(pointer(L:MemLoc, MI:MInt), N:Int, V:StoreVal)
             =>
           writeMem(L, uvalueMInt(MI) *Int 8, toMemValue(N, V))
       </k>
  
  rule toMemValue(N:Int, V:StoreVal) => memList(N /Int 8, 8, toStackList(V, N, .StackList))
  
  rule toStackList(MI:MInt, N:Int, D:StackList)
         =>
       toStackListFromMInt(MI, N, D)
         requires bitwidthMInt(MI) ==Int N
  
  rule toStackListFromMInt(MI:MInt, N:Int, D:StackList)
         =>
       appendStackList(D, toBytes(N, MI))
  
  rule appendStackList(D1:StackList, D2:StackList)
         =>
       reverseAppendList(reverseList(D1), D2)
  
  /*
   *  MInt to byte
   */
  rule toBytes(N:Int, MI:MInt) => toBytesHelper(N /Int 8, MI, .StackList)
  
  rule toBytesHelper(0, _:MInt, D:StackList) => D
  
  rule toBytesHelper(I:Int, MI:MInt, D:StackList)
         =>
       toBytesHelper(I -Int 1, MI, byte(I -Int 1, MI) D)
         requires I >Int 0
  
  rule <k>
           writeMem(memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, memList(E:Int, EBits:Int, D:StackList))
             =>
           .
       ...</k>
       <stackstate>
         mem(M:Map => writeToMem(M, memLoc(BID, Al, N, S, I), Off, memList(E:Int, EBits:Int, D:StackList)))
       </stackstate>
       <freedstate>
         F:MemorySet
       </freedstate>
         requires notBool inMemorySet(memLoc(BID, Al, N, S, 0), F)
                  andBool Off >=Int 0 andBool E >=Int 0
                  andBool Off +Int E *Int EBits <=Int N *Int S
  
  rule <k>
           writeMem(memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, memList(E:Int, EBits:Int, D:StackList))
             =>
           error(OutOfAccessMemoryBound)
       ...</k>
       <stackstate>
         M:Memory
       </stackstate>
       <freedstate>
         F:MemorySet
       </freedstate>
         requires inMemorySet(memLoc(BID, Al, N, S, 0), F)
                  orBool notBool (Off >=Int 0 andBool E >=Int 0
                  andBool Off +Int E *Int EBits <=Int N *Int S)
  
  rule writeToMem(M:Map, memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, memList(E:Int, EBits:Int, D:StackList))
         =>
       writeToMemHelper(memLoc(BID, Al, N, S, I), Off /Int S, E, D, M)
         requires S ==Int EBits
  
  rule writeToMemHelper(memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, E:Int, D:StackList, M:Map)
         =>
       M
         requires E ==Int 0
  
  rule writeToMemHelper(memLoc(BID:Int, Al:Int, N:Int, S:Int, I:Int), Off:Int, E:Int, V:StackData D:StackList, M:Map)
         =>
       writeToMemHelper(memLoc(BID, Al, N, S, I), Off +Int 1, E -Int 1, D,
                        storeMemory(M, memLoc(BID, Al, N, S, I +Int Off), V))
         requires E >Int 0
  
endmodule
