#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../PsCom/

cd $K_DIR

touch single-Inst-test/vmax.test
touch single-Inst-test/vmax-test.out
gcc bignum/rand_vmax.c -o bignum/rand_vmax

# output the test case to "test.s"
./bignum/rand_vmax > single-Inst-test/vmax.test

starttime=`date +'%Y-%m-%d %H:%M:%S'`

# run the test case "test.s" and output to the "test.out"
krun single-Inst-test/vmax.test --output-file "single-Inst-test/vmax-test.out"

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo "本次运行时间： "$((end_seconds-start_seconds))"s"

