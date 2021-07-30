#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../k-armv8.1-m/

cd $K_DIR

touch single-Inst-test/vminnm-s2.test
touch single-Inst-test/vminnm-s2-test.out
gcc bignum/rand_vminnm-s2.c -o bignum/rand_vminnm-s2

# output to the test case
./bignum/rand_vminnm-s2 > single-Inst-test/vminnm-s2.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vminnm-s2.test --output-file "single-Inst-test/vminnm-s2-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

