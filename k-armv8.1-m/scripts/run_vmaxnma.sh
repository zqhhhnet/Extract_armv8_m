#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../PsCom/

cd $K_DIR

touch single-Inst-test/vmaxnma.test
touch single-Inst-test/vmaxnma-test.out
gcc bignum/rand_vmaxnma.c -o bignum/rand_vmaxnma

# output to the test case
./bignum/rand_vmaxnma > single-Inst-test/vmaxnma.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vmaxnma.test --output-file "single-Inst-test/vmaxnma-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

