SET SERVEROUTPUT ON
whenever sqlerror exit 1;
CLEAR BUFF
CLEAR COMPUTE
CLEAR BREAKS
CLEAR COLUMNS
/*-----------------------------------------------------------------------------
Name         : 

Revison History :
     1.0 - Cognizant Offshore -  08/01/2017 - Initial Version
-----------------------------------------------------------------------------*/
SET PAGESIZE 50000 EMBEDDED ON
SET ECHO OFF
SET TERMOUT OFF
SET LINESIZE 143
SET FEEDBACK OFF

SPOOL '&1'

BREAK ON REPORT
COMPUTE SUM LABEL 'TOTAL_PREMIUM' OF TOTAL_PREM ON REPORT

SELECT 
TO_CHAR(sysdate, 'DD/MM/YY') AS RUN_DATE,
TO_CHAR(SYSDATE,'HH24:MI:SS') AS RUN_TIME,
contract,
pmt_due_dt,
first_prem,
fee,
second_prem,
TOTAL_PREM,
reason
FROM 
PAYMENT_STAGE;

SPOOL OFF;
SET TERMOUT ON
EXIT;
