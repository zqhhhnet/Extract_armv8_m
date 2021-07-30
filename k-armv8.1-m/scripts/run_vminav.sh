#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../k-armv8.1-m/

cd $K_DIR

touch single-Inst-test/vminav.test
touch single-Inst-test/vminav-test.out
gcc bignum/rand_vminav.c -o bignum/rand_vminav

# output to the test case
./bignum/rand_vminav > single-Inst-test/vminav.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vminav.test --output-file "single-Inst-test/vminav-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

