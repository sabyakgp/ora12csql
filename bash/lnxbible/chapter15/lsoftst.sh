#!/bin/bash
#redirect file descriptors and show them using lsof
exec 3> test3
exec 4> test4
exec 6> test6
/usr/bin/lsof -a -p $$ -d 0,1,2,3,3,6,7
/usr/bin/lsof -a -p $$ d 0,1,2,3,3,6,7 2> lsoferr

