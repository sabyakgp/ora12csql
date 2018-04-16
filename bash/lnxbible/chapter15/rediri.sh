#!/bin/bash
#redirect STDIN to FD#6
exec 6<&0
#redirect STDIN to input
exec 0<input
count=1
while read line
do
	echo "Line #$count: $line"
	count=$[ $count + 1 ]
done
#now reset STDIN - 
exec 0<&6
read -p "Are you done?" answer
case $answer in
Y|y) echo "Goodbye!";;
N|n) echo "You have no option!";;
esac
