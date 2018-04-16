#!/bin/bash
divider="---------------------"
length=50
divider=$divider$divider
length=50
header="\n%-10s    %10s          %6s\n"
clear
printf "%-${length}s\n" $divider
printf "     %10s\n" "Employee Age and Salary Report"
printf "%-${length}s\n" $divider
printf "$header" NAME AGE SALAY
printf "%-${length}s\n" $divider
format="%-10s           %2d           %5.2f"
header="\n%-10s    %10s          %6s\n"
printf "$format\n" Sabyasachi 32 2345.29
