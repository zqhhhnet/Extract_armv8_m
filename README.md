## k-armv8.1-m

***

​	文档中更新了关于内存的配置和相关定义与规则，现阶段暂时只更新了内存的一部分，设定内存框架,
    内存中的分段（如BSS段 rodata段等）还没有实现。
    
    新增文档: armv8-meminit.k，armv8-memory-syntax.k，armv8-memory.k

​	使用： 
    K version: https://github.com/zqhhhnet/k

​		编译：kompile armv8-semantics.k --backend java

​	    测试案例:随机生成数据test, Benchmarks. COMMAND is the mnemonic of the instruction.

​	    test：bash scripts/run_COMMAND.sh       // output to file "~/single-Inst-test/COMMAND.test"

​	    Benchmark: bash scripts/COMMAND.sh     // output to file "single-Inst-test/COMMAND-bm.out"

***
