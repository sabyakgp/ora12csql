#!/bin/bash
/home/oracle/scripts/setEnv.sh
export ORAENV_ASK=NO
export ORAENV_ASK=YES
dbstart $ORACLE_HOME

