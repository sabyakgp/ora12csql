/**********************************************************************************************************************************
** Table Name     : EMBT_FCTS_MPWR_DTL_STG                                                                                       **
** Purpose        : Please enter the purpose of table                                                                            **
** Version Number : 1.0                                                                                                          **
** Version   Date           Developer                   Description                                                              **
** --------  -----------    --------------------        ------------------------                                                 **
** 1.0       07/10/2017      Cognizant Offshore         Initial Version  														 **
**********************************************************************************************************************************/

/***************************************************************************
**   DROP TABLE IF AVAILABLE                                             **
***************************************************************************/

DECLARE
BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE EMBT_FCTS_MPWR_DTL_STG';
EXCEPTION
     WHEN OTHERS THEN
        NULL;
END;
/
/***************************************************************************
**   CREATING TABLE                                                       **
***************************************************************************/

CREATE TABLE EMBT_FCTS_MPWR_DTL_STG (
REC_TYPE              VARCHAR2(2),
MCO_CONTRACT_NUM      VARCHAR2(5)  ,
PLAN_BNFT_ID          VARCHAR2(3)  ,
PLAN_SEG_ID           VARCHAR2(3)  ,
HIC_NUM               VARCHAR2(12) ,
SURNAME               VARCHAR2(7)  ,
FIRST_INITIAL         VARCHAR2(1)  ,
SEX                   VARCHAR2(1)  ,
DATE_OF_BIRTH         DATE   ,
PREM_PMT_OPT          VARCHAR2(4)  ,
BLANK                 VARCHAR2(1)  ,
PREM_START_DT         DATE  ,
PREM_END_DT           DATE,
MONTH_NUM             VARCHAR2(2)  ,
PREM_AMT_C            NUMBER(18,4) ,
PREM_AMT_D            NUMBER(18,4) ,
PENL_AMT_D            NUMBER(18,4) 
)
ORGANIZATION EXTERNAL (
TYPE ORACLE_LOADER
DEFAULT DIRECTORY DEV_EXTERNAL
ACCESS PARAMETERS (
RECORDS DELIMITED BY NEWLINE
LOAD WHEN (REC_TYPE = "D")
FIELDS LRTRIM
(
	REC_TYPE              CHAR(2),
	MCO_CONTRACT_NUM      CHAR(5),
	PLAN_BNFT_ID          CHAR(3),
	PLAN_SEG_ID           CHAR(3),
	HIC_NUM               CHAR(12),
	SURNAME               CHAR(7),
	FIRST_INITIAL         CHAR(1),
	SEX                   CHAR(1),
	DATE_OF_BIRTH         CHAR(8) date_format date mask "YYYYMMDD",
	PREM_PMT_OPT          CHAR(3), 
	BLANK                 CHAR(1),
	PREM_START_DT         CHAR(8) date_format date mask "YYYYMMDD",
	PREM_END_DT           CHAR(8) date_format date mask "YYYYMMDD",
	MONTH_NUM             CHAR(2), 
	PREM_AMT_C            CHAR(8), 
	PREM_AMT_D            CHAR(8),
	PENL_AMT_D            CHAR(8)
)
)
LOCATION ('H3330.MPWRD.R201706.D170601.T1407150')
)
REJECT LIMIT UNLIMITED;

