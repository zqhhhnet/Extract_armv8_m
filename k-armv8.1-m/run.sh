#!/bin/bash

THIS_DIR="$(pwd)"
K_DIR=$THIS_DIR/../k-armv8.1-m/

cd $K_DIR

gcc rand_max.c -o rand

# output the test case to "test.s"
./rand > test.s

# run the test case "test.s" and output to the "test.out"
krun test.s --output-file test.out
