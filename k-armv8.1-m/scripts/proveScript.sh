#!/bin/bash

element1=$1
element2=$2
element3=$3
element4=$4
filename=""
smt_prelude_path=""
if [ $element1 == "--file" ]
then
    filename=${element2}
elif [ ${element3} == "--file" ]
then
    filename=${element4}
else
    echo '## Error options, check the form.'
    echo '## For example: '
    echo '  --file              [prove_Filename]'
    echo '  --smt-prelude       [Smt_prelude_path]'
    echo '      Path to SMT prelude file.'
    echo '  ## smt_prelude_path: ~/KFramework_ROOT_PATH/k-distribution/include/z3/basic.smt2'
    echo '  ## KFramework_ROOT_PATH, the path of K Framework root file you installed'
    exit
fi

if [ ${element1} == "--smt-prelude" ]
then
    smt_prelude_path=${element2}
elif [ ${element3} == "--smt-prelude" ]
then
    smt_prelude_path=${element4}
elif [[ ! ${element3} ]]
then
    java -jar scripts/proveScript-1.0.jar --file ${filename}
    exit
else
    echo '## Error options, check the form.'
    echo '## For example: '
    echo '  --file              [prove_Filename]'
    echo '  --smt-prelude       [Smt_prelude_path]'
    echo '      Path to SMT prelude file.'
    echo '  ## smt_prelude_path: ~/KFramework_ROOT_PATH/k-distribution/include/z3/basic.smt2'
    echo '  ## KFramework_ROOT_PATH, the path of K Framework root file you installed'
    exit
fi
# smt_prelude_path: ~/KFramework_ROOT_PATH/k-distribution/include/z3/basic.smt2
# KFramework_ROOT_PATH, the path of K Framework root file you installed.
java -jar scripts/proveScript-1.0.jar --file ${filename} --smt-prelude ${smt_prelude_path}

