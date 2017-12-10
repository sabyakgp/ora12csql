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
     CURSOR
        cur_get_obj
     IS
     SELECT obj.object_name,
            obj.owner,
            obj.object_type
     FROM
          all_objects obj
     WHERE obj.object_name = 'EMBT_FCTS_MPWR_DTL_STG'
     AND   obj.owner       = 'FACETS_STAGE';
BEGIN
     FOR obj_list IN cur_get_obj
     LOOP
         EXECUTE IMMEDIATE 'DROP '||obj_list.object_type||' '||obj_list.owner||'.'||obj_list.object_name;
     END LOOP;
EXCEPTION
     WHEN OTHERS THEN
        NULL;
END;
/
/***************************************************************************
**   CREATING TABLE                                                       **
***************************************************************************/

CREATE TABLE FACETS_STAGE.EMBT_FCTS_MPWR_DTL_STG (
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
DEFAULT DIRECTORY EMB_FACETSSI_DIR
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
LOCATION ('embf_fcts_mpwr.txt')
)
REJECT LIMIT UNLIMITED;

/***************************************************************************
**   GRANTS FOR THE ABOVE TABLE                                          **
***************************************************************************/

GRANT
SELECT
ON FACETS_STAGE.EMBT_FCTS_MPWR_DTL_STG TO FACETS_CUSTOM,FACETS_LOAD, DEVELOPER;
