#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../k-armv8.1-m/

cd $K_DIR

touch single-Inst-test/vmlav.test
touch single-Inst-test/vmlav-test.out
gcc bignum/rand_vmlav.c -o bignum/rand_vmlav

# output the test case to "test.s"
./bignum/rand_vmlav > single-Inst-test/vmlav.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case "test.s" and output to the "test.out"
krun single-Inst-test/vmlav.test --output-file "single-Inst-test/vmlav-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

