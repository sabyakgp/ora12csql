/*-----------------------------------------------------------------------------
Name         : EMBT_FCTS_MPWR.sql

Revison History :
     1.0 - Cognizant Offshore -  07/10/2017 - Initial Version 
-----------------------------------------------------------------------------*/

WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
SET SERVEROUTPUT ON;

SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 4000
SET TRIMSPOOL ON
SET SPACE 0
SET WRAP OFF


SPOOL '&1'
SELECT 
     NVL2(KWD_GRGR_ID,'@pRCPT_INPUT_GRGR_ID="' || RTRIM(TO_CHAR(NVL(KWD_GRGR_ID, ''))) || '"', '@pRCPT_INPUT_GRGR_ID=" "')
    || NVL2(KWD_SBSB_ID,',@pRCPT_INPUT_SBSB_ID="' || TO_CHAR(NVL(RTRIM(KWD_SBSB_ID), ' ')) || '"', ',@pRCPT_INPUT_SBSB_ID=" "') 
    || NVL2(trim(to_char(KWD_RCPT_AMT,'S9999999.99')),',@pRCPT_AMT=' || RTRIM(NVL(trim(to_char(KWD_RCPT_AMT,'S9999999.99')),0)), '')
    || NVL2(KWD_RCPT_RCVD_DT,',@pRCPT_RCVD_DT="' || RTRIM(to_char(KWD_RCPT_RCVD_DT, 'MM/DD/YYYY')) || '"', '')
    || NVL2(KWD_RCPT_PAY_METH,',@pRCPT_PAY_METH="' || RTRIM(TO_CHAR(NVL(KWD_RCPT_PAY_METH, ' '))) || '"', '')
    || NVL2(KWD_RCPT_CD,',@pRCPT_RCPT_CD="' || RTRIM(TO_CHAR(NVL(KWD_RCPT_CD, ' '))) || '"', '')
    || NVL2(KWD_RCPT_MCTR_RSN,',@pRCPT_MCTR_RSN="' || RTRIM(TO_CHAR(NVL(KWD_RCPT_MCTR_RSN, ' '))) || '"', '') 
    || ',@p_Class="CMC_APPREC_RCPT_EXTERNAL"'
FROM FACETS_STAGE.EMBT_MPWR_RCPT_KWD;				
SPOOL OFF

SET PAGESIZE 24
SET LINESIZE 80
SET FEEDBACK ON
SET TERMOUT ON

EXIT

