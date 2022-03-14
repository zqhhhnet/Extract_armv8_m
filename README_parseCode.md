### 调用 kprove 进行验证

---

#### Kframework-5.0.0

​	该文档是KFramework的代码框架，用于测试，用法如下：

​		1.安装KFramework的依赖，如该版本所需依赖： https://github.com/zqhhhnet/k

​		2.完成1后，切换到Kframework-5.0.0中，输入以下命令即可完成KFramework的安装

​			`mvn package -DskipTests`

​		3.将工具路径设置到环境变量中，工具路径为：

​			`~/Kframework-5.0.0/k-distribution/bin`

​		4.卸载：若更改源代码后，需要重新编译，则在Kframework-5.0.0文档中，输入以下命令清空之前的编译，之后再执行2中的命令重新编译即可：

​			`mvn clean`

---

#### Branch: test

​	运用kprove工具验证需要运用test分支。

​	test分支是关于调用kprove验证指令的代码，用法如下：

​		1.当完成上述Framework工具的安装后，切换到test分支中的文档，并执行如下编译命令：

​			`kompile armv8-semantics.k --backend java`

​		2.完成编译后，执行以下命令可进行指令验证，如对vmin指令数据类型为S8的验证，其验证规则在test-spec-vmin-s8.k中：

​			`kprove test-spec-vmin-s8.k -v --debug-z3 `

​			其中test-spec-vmin-s8.k为所要验证的程序，-v是打印输出信息，--debug-z3是打印关于Z3的debug信息. 

​			在kprove输出的信息中,以 SMT query  @@@@@ 为开头 和 以 SMT query  ##### 为结尾的,是在这次kprove验证中调用Z3证明的query信息.

---

#### 关于KFramework的kprove在源代码中的执行路径:

以下是其大致路径,#开头的为接口所在的.java文件,如main()接口在Main.java文件中.

	#Main.java: main() ->	// 入口
	    getInjector()->		// 设置kprove前端,以及进行类接口封装
		runApplication()->	// kproveFrontEnd的主程序入口
	    	frontEnd.get().main()->		// 载入需要解析的信息,并运行解析和验证的接口
	        	#FrontEnd.java: main()->	 
	            	#KProveFrontEnd.java: run()->
	                	#KProve.java: run()->
	                    	getProofDefinition()->	// 运行解析部分
	                    	rewriter.prove()->		// 进入验证接口
	                        	#InitializeRewriter.java: prove()->
	                            	rewriter.proveRule()->
	                                	#SymbolicRewriter.java: proveRule()->
	                                    	... // implies函数用于验证LHS和RHS的蕴含关系,细节还没搞清楚
	                                    	#ConstrainedTerm.java: implies()->
	                                            #ConjunctiveFormula.java: implies()->
	                                                impliesSMT()->
	                                                    #SMTOperations.java: impliesSMT()->
	                                                        z3.isUnsat()->
	                                                            #Z3Wrapper.java: isUnsat()	//检测query是否unsat
	                                                            
