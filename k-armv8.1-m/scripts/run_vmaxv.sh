#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../PsCom/

cd $K_DIR

touch single-Inst-test/vmaxv.test
touch single-Inst-test/vmaxv-test.out
gcc bignum/rand_vmaxv.c -o bignum/rand_vmaxv

# output to the test case
./bignum/rand_vmaxv > single-Inst-test/vmaxv.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vmaxv.test --output-file "single-Inst-test/vmaxv-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

