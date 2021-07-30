#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../k-armv8.1-m/

cd $K_DIR

touch single-Inst-test/vminnmav.test
touch single-Inst-test/vminnmav-test.out
gcc bignum/rand_vminnmav.c -o bignum/rand_vminnmav

# output to the test case
./bignum/rand_vminnmav > single-Inst-test/vminnmav.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vminnmav.test --output-file "single-Inst-test/vminnmav-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

