#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../PsCom/

cd $K_DIR

touch single-Inst-test/vmaxnm-d2d.test
touch single-Inst-test/vmaxnm-d2d-test.out
gcc bignum/rand_vmaxnm-d2d.c -o bignum/rand_vmaxnm-d2d

# output to the test case
./bignum/rand_vmaxnm-d2d > single-Inst-test/vmaxnm-d2d.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case and output
krun single-Inst-test/vmaxnm-d2d.test --output-file "single-Inst-test/vmaxnm-d2d-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

