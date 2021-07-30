#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../k-armv8.1-m/

cd $K_DIR

touch single-Inst-test/vmina.test
touch single-Inst-test/vmina-test.out
gcc bignum/rand_vmina.c -o bignum/rand_vmina

# output to the test case
./bignum/rand_vmina > single-Inst-test/vmina.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vmina.test --output-file "single-Inst-test/vmina-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

