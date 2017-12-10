WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
SET SERVEROUTPUT ON;
/*-----------------------------------------------------------------------------
Name         : EMBS_5SB_SPOOL

Revison History :
     1.1 - Cognizant Offshore -  09/24/2016 - Initial Version
	 1.2 - Cognizant Offshore -  04/13/2017 - Updated Report Header and Center for Group structure changes 
-----------------------------------------------------------------------------*/
CLEAR BUFF
SET PAGESIZE 100
SET ECHO OFF
SET TERMOUT OFF
SET LINESIZE 133
SET FEEDBACK OFF
SET HEADER OFF
SET HEADING OFF
SET TTITLE OFF 
SET UNDERLINE OFF
SET REPHEADER ON

SPOOL '&1'
COLUMN RUN_DATE NEW_VALUE RDTE NOPRINT
COLUMN RUN_TIME NEW_VALUE RTIME NOPRINT 
REPHEADER LEFT 'PROGRAM NO: CMS PAYMENT REPORT' CENTER '***  HIP OF GREATER NY ***' -
RIGHT 'PAGE NO:         1' -
SKIP 1 COL 116 'RUN DATE: ' RDTE -
SKIP 1 COL 116 'RUN TIME: ' RTIME -
SKIP 2 COL 53  'E R R O R    R E P O R T' - 
SKIP 1 COL 50 '-----------------------------' -
SKIP 1 COL 50 'FOR CMS MEDICARE PAYMENT FILE' -
SKIP 1 COL 50 'HCIN H3330  AS OF ' COL 69 RDTE -	
SKIP 2 COL 4 'MEDICARE' COL 19 'PAYMENT' COL 35 'PART C' COL 50 'PART D' COL 65 'PART D' COL 83 'TOTAL' COL 108 'REASON' -
SKIP 1 COL 2 'CLAIM NUMBER' COL 19 'DUE DATE' COL 34 'PREMIUMS' COL 49 'PREMIUMS' COL 64 'PENALTIES' COL 80 'PREMIUM AMT' COL 107 'FOR ERROR' -
SKIP 1 COL 1 '--------------' COL 18 '------------' COL 33 '-----------' COL 48 '-----------' COL 63 '------------' COL 79 '-------------' COL 98 '---------------------------------'


SELECT 
	LPAD(' ',1)                          || 	
	HICN_NBR                             ||  
	LPAD(' ',6)                          ||
	PYMT_DUE_DT                          || 
	LPAD(' ',4)                          ||
	TO_CHAR(PART_C_PREM, 'B99999999.99') ||
   	LPAD(' ',3)                          ||
	TO_CHAR(PART_D_PREM, 'B99999999.99') ||
	LPAD(' ',4)                          ||
	TO_CHAR(PART_D_LEP,  'B99999999.99') ||
	LPAD(' ',5)                          ||
	TO_CHAR(TOTL_PREM,  'B99999999.99')  ||
	LPAD(' ',6)                          ||
	REASON_DESC,
	TO_CHAR(SYSDATE,'MM/DD/YY') RUN_DATE,
	TO_CHAR(SYSDATE,'HH24:MI:SS') RUN_TIM
FROM 
(
	SELECT 
		'114462077D1' AS HICN_NBR,
		'01-JUN-17'   AS PYMT_DUE_DT,
		 45 AS PART_C_PREM,
		 45 AS PART_D_PREM,
		 10 AS PART_D_LEP,
		 90 AS TOTL_PREM,
		 'INVALID MEDICARE CLAIM NUMBER' AS REASON_DESC
	FROM 
		DUAL
);
SPOOL OFF;
SET TERMOUT ON
