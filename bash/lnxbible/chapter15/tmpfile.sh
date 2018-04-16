#!/bin/bash
#create a temp. file in local directory, write a few lines, display its contents and dispose it
tempfile=$(mktemp temptest.XXXXXX)
exec 3>$tempfile
echo "Start writting in $tempfile file"
echo "Writting in $tempfile" >&3
exec 3>&-
cat $tempfile
rm -f temptest*
#create temporary files in /tmp directory
tempfile=$(mktemp -t temptest.XXXXXX)
exec 3>$tempfile
echo "Start writting in $tempfile file"
echo "Writting in $tempfile" >&3
exec 3>&-
cat $tempfile
