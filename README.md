# Extract_armv8_m

=== Using OCaml to extract the pesudocode of the instruction of Armv8.1-m architecture manual.===



## k-armv8.1-m

***

​	文档中，包含用K Framework 对Armv8.1-M中指令语义进行形式化的代码

​	使用： 
    K version: https://github.com/zqhhhnet/k

​		编译：kompile armv8-semantics.k --backend java

​		运行：krun test.s --output-file "test.out"	//此处test.s为测试用例，结果输出到test.out中

***

***

​	各文档：

​		armv8-syntax.k： arm指令语法

​		armv8-verification-lemmas.k：关于float、MInt、Int类型转换的语法和规则

​		armv8-mint.k：关于MInt的语法和规则

​		armv8-verification.k : 对K中基本库函数进行一些规则上的修改，使其更契合arm中指令需要的功能

​		armv8-abstract-syntax.k：对指令进行抽象操作的相关语法

​		armv8-abstract-semantic.k：对指令进行抽象操作的规则

​		armv8-configuration.k：配置其环境

​		armv8-loader.k：读取指令

​		vmax.k：armv8.1-m 中的 VMAX指令，整数形式的规则，例：vmax.S8 q0, q1, q2

​		vmaxnm.k：VMAXNM指令，浮点数形式规则，例： vmaxnm.F32 q1, q2, q3

​		armv8-semantics.k：整合以上文档，编译

​		test.s：测试用例

​		test.out：测试结果

***
