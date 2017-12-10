WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
SET SERVEROUTPUT ON;
/*-----------------------------------------------------------------------------
Name         : EMBS_5SB_SPOOL

Revison History :
     1.1 - Cognizant Offshore -  09/24/2016 - Initial Version
	 1.2 - Cognizant Offshore -  04/13/2017 - Updated Report Header and Center for Group structure changes 
-----------------------------------------------------------------------------*/

SET ECHO OFF
SET TERMOUT OFF
SET LINESIZE 133
SET FEEDBACK OFF
SET HEADER OFF
SET TTITLE OFF 
SET UNDERLINE OFF
SET REPHEADER ON

SPOOL '&1'
COLUMN RUN_DATE NEW_VALUE RDTVAR NOPRINT
COLUMN RUN_TIME NEW_VALUE RTVAR NOPRINT
REPHEADER LEFT 'PROGRAM NO: FACETS GROUP BILLING' CENTER '***  HIP OF GREATER NY ***' - 
RIGHT 'PAGE NO:         1' - 
SKIP 1 COL 116 'RUN DATE: 'RDTVAR - 
SKIP 1 COL 116 'RUN TIME: 'RTVAR -
SKIP 2 CENTER 'BILLING CYCLE CONTROL REPORT FOR FACETS GROUP BILLING' -
SKIP 3 COL 13 'HIP FACETS GROUP BILLING' COL 97 'INVOICES RUN SUMMARY' - 
SKIP 3 COL 34 '--------------------------------------------------------------------' - 
SKIP 3 COL 16 '1ST INVOICE NUMBER               PYMT DUE DATE               # OF STMTS               TOT BLD AMT' - 
SKIP 3 COL 34 '--------------------------------------------------------------------' - 


SELECT 
      LPAD(bliv_id,33,' ')||
      LPAD(TO_CHAR(blbl_due_dt,'MON.YYYY'),25,' ')||
      LPAD(tot_no_inv,28,' ')||
      CASE WHEN sum_billed_amt >=0 
				THEN
				(LPAD(TO_CHAR(sum_billed_amt,'$99,999,999,999,990.99'),26,' ')|| ' ')
				ELSE
				(LPAD(TO_CHAR(sum_billed_amt,'$99,999,999,999,990.99S'),26,' '))
	  END AS " ",
	  TO_CHAR(SYSDATE,'MM/DD/YY')   RUN_DATE,
	  TO_CHAR(SYSDATE,'HH24:MI:SS') RUN_TIME
FROM
(
  SELECT 
      bliv_id, 
      blbl_due_dt,
      COUNT(DISTINCT bliv_id) OVER () tot_no_inv,
      SUM(SUM(DISTINCT payment_amt)) OVER() sum_billed_amt
  FROM 
      facets_stage.embt_comm_prem_dtl A
      group by  
      bliv_id, 
      blbl_due_dt
  ORDER BY 
      bliv_id
)
WHERE ROWNUM =1
UNION ALL
SELECT ' ' AS " ",TO_CHAR(SYSDATE,'MM/DD/YY') RUN_DATE, TO_CHAR(SYSDATE,'HH24:MI:SS') RUN_TIME FROM DUAL;
SPOOL OFF;
SET TERMOUT ON
EXIT;