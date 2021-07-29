#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../PsCom/

cd $K_DIR

touch single-Inst-test/vmaxav.test
touch single-Inst-test/vmaxav-test.out
gcc bignum/rand_vmaxav.c -o bignum/rand_vmaxav

# output to the test case
./bignum/rand_vmaxav > single-Inst-test/vmaxav.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vmaxav.test --output-file "single-Inst-test/vmaxav-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

