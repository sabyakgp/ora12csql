#!/bin/bash
#closing file descriptior
exec 3> input
echo "This is to test FD close" >&3
#now close FD-3
exec 3>&-
echo "This will not appear in input file" 2> badfile 1>&3
exit 0
