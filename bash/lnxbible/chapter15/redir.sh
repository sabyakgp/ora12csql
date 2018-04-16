#!/bin/bash
#permanent redirection
exec 2>>testerror
echo "this will go to terminal"
exec 1>>output
echo "this should go to testerror" >&2
echo "this should go to output"
echo "this too should go to output" >&1
exit 0
#redirecting user defined error message to error file instead of STDOUT
echo "This an user defined error message" >&2
exit 0
#to redirect output and error to two files
ls -al f1 f2 f3 1> opt 2> error
#exit 0
#to redirect output and error to same file
echo to same file
ls -al f1 f2 f3 &> operr

