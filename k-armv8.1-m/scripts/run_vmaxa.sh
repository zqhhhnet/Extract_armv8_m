#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../PsCom/

cd $K_DIR

touch single-Inst-test/vmaxa.test
touch single-Inst-test/vmaxa-test.out
gcc bignum/rand_vmaxa.c -o bignum/rand_vmaxa

# output to the test case
./bignum/rand_vmaxa > single-Inst-test/vmaxa.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vmaxa.test --output-file "single-Inst-test/vmaxa-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

