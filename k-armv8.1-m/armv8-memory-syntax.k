require "armv8-configuration.k"

module MEMORY-SORTS
    
  syntax MemLoc			[smt-prelude]
  syntax MemValue
  syntax StackList		[smt-prelude]
  //syntax MemoryMap
  syntax Memory
  syntax MemorySet		[smt-prelude]
    
endmodule

module MEMORY-MAP-SYNTAX
  
  //syntax MemoryMap ::= ".MemoryMap"  [function]
  
endmodule

module MEMORY-SET-SYNTAX

  imports MEMORY-SORTS
  
  syntax MemorySet ::= ".MemorySet"		[function, smtlib(smt_set_emp)]
  
  // check MemLoc exist
  syntax Bool ::= inMemorySet(MemLoc, MemorySet)
    [function, smtlib(smt_set_mem)]

  // Add a MemLoc to the set.
  syntax MemorySet ::= addMemorySet(MemorySet, MemLoc)
    [function, smtlib(smt_set_add)]

endmodule

module ARMV8-MEMORY-SYNTAX
  imports MEMORY-SORTS
  imports MINT
  imports INT
  imports MAP
  
  //syntax MemoryMap ::= Map
  
  //rule .MemoryMap => .Map
  
  syntax MemLoc ::= memLoc(/* block ID */ Int,
                           /* bits of system */ Int,
                           /* block size in elements */ Int,
                           /* element size in bits */ Int,
                           /* offset */ Int)	[smtlib(symloc), smt-prelude]
  
  syntax KItem ::= alloc(/* system align in bits */ Int,
                         /* size of elements space */ Int,
                         /* element size in bits */ Int)
  
  syntax Pointer ::= pointer(MemLoc, MInt)
  
  syntax MInt ::= Pointer
  
  syntax StackData ::= byte(/* element index */ Int,
                            /* MInt of data */ MInt)
  
  syntax StackData ::= getDefaultValue()  [function]
  
  syntax StackList ::= ".StackList" 			[smtlib(emptyMemData)]
                     | StackData StackList		[smtlib(memData)]
  
  syntax StackList ::= takeStackList(Int, StackList) [function]
                     | takeStackListHelper(Int, StackList, StackList) [function]
                     | reverseList(StackList)  [function]
                     | reverseAppendList(StackList, StackList) [function]

  
  
  
  syntax Map ::= storeMemory(Map, MemLoc, StackData)  [function, smtlib(store)]
  
  syntax Map ::= writeToMem(Map, MemLoc, /* offset in bits */ Int,
                                  /* store data list */ MemValue)  [function]
                     | writeToMemHelper(MemLoc, Int, 
                                        /* number of store data */ Int,
                                        StackList, Map)  [function]
  
  syntax StackData ::= selectMemory(Map, MemLoc)  [function, smtlib(select)]
  
  syntax Memory ::= mem(Map)
                     
  
  syntax KItem ::= loadFromMemory(Pointer, /* bits of read data */ Int)
                 | fromMemoryRead(KItem, /* bits */ Int)
                 
  syntax StoreVal ::= MInt
  
  syntax KItem ::= storeToMemory(Pointer, /* bits of write */ Int, StoreVal)
                 
  
  syntax KItem ::= readMem(MemLoc,
                           /* offset in bits */ Int,
                           /* elements number */ Int,
                           /* element size in bits */ Int)
                 | writeMem(MemLoc,
                            /* offset in bits */ Int,
                            /* value */ MemValue)
  
  syntax MemValue ::= memList(/* elements number */ Int,
                              /* per element size in bit */ Int,
                              /* data in memory */ StackList)
                    | toMemValue(/* bits of store data */ Int,
                                 /* store value */ StoreVal)  [function]
                    
  
  syntax MemValue ::= readMemValue(MemLoc,
                                   /* offset */ Int,
                                   /* number of read element */ Int,
                                   /* per element size in bit */ Int,
                                   /* memory map */ Memory)  [function]

  syntax StackList ::= readMemValueHelper(MemLoc,
                                          /* offset */ Int,
                                          /* element number */ Int,
                                          /* memory map */ Map,
                                          /* data list */ StackList) [function]

  syntax StackList ::= toStackList(StoreVal, Int, StackList) [function]
                     | toStackListFromMInt(/* MInt of value */ MInt,
                                          /* N bits to store */ Int,
                                          /* change to datalist */ StackList) [function]
                     | appendStackList(StackList, StackList) [fuction]
                     | toBytes(/* bits of store data */ Int,
                               /* store data */ MInt)  [function]
                     | toBytesHelper(Int, MInt, StackList) [function]
  
  // to get the value from load
  syntax MIntOfLoadValue ::= mintOfLoadValue(MInt)
  
  syntax MInt ::= byteToMInt(StackList)  [function]
  
  syntax KItem ::= allocStackPointer(/* alignment in bits, i.e size of bitvector */ Int,
                                     /* top of stack pointer */ Int)
                                     
  syntax KItem ::= saveStackPointer(KItem) [strict(1)]
                 | allocLocalMemory(/* align */ Int, /* size of elements */ Int)
  
  syntax KResult ::= MemValue
                   | MemLoc
  
  syntax Error ::= "OutOfAccessMemoryBound"
  
  syntax KItem ::= error(Error)
  
  
endmodule

module MEMORY-CONFIGURATION
  
  imports MEMORY-SORTS
  imports ARMV8-MEMORY-SYNTAX
  imports MEMORY-SET-SYNTAX
  imports MEMORY-MAP-SYNTAX
  
  /*
   *  add nextlocid to configuration to set the block id
   */
  configuration
    <memorystate>
      <nextlocid> 1 </nextlocid>
      <stackstate>
          //mem(.MemoryMap)
          mem(.Map)
      </stackstate>
      <freedstate>
          .MemorySet
      </freedstate>
    </memorystate>
  

endmodule

