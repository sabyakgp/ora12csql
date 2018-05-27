define _editor=subl
set serveroutput on size 1000000
set trimspool on
set long 5000
set linesize 200
set pagesize 9999
column plan_plus_exp format a80
set sqlprompt '&_user.@&_connect_identifier.> '