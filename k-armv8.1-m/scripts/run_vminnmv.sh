#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../k-armv8.1-m/

cd $K_DIR

touch single-Inst-test/vminnmv.test
touch single-Inst-test/vminnmv-test.out
gcc bignum/rand_vminnmv.c -o bignum/rand_vminnmv

# output to the test case
./bignum/rand_vminnmv > single-Inst-test/vminnmv.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vminnmv.test --output-file "single-Inst-test/vminnmv-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

