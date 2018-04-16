#!/bin/bash
#redirects input and output to the same file
exec 3<> inout
#echo "This is first line" >&3
#echo "This second line" >&3
read line <&3
echo "Read: $line"
echo "This is third line" >&3
