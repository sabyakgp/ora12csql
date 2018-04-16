#!/bin/bash
#creating an alternative file descriptorcreating your own redirection
#redirect FD#3 to standard output
exec 3>&1
echo "this will go to terminal" >&3
#redirect STDOUT to testout
exec 1>testout
echo "this will go to testout"
echo "but this will still go to terminal" >&3
echo "but this will go to testout again" >&1
#now redirect STDOUT from testout to FD#3 which is already redirected to STDOUT
exec 1>&3
echo "this should go back to terminal"
