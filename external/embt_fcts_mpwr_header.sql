/**********************************************************************************************************************************
** Table Name     : EMBT_FCTS_MPWR_HEADER                                                                                        **
** Purpose        : Please enter the purpose of table                                                                            **
** Version Number : 1.0                                                                                                          **
** Version   Date           Developer                   Description                                                              **
** --------  -----------    --------------------        ------------------------                                                 **
** 1.0       07/10/2017       Cognizant Offshore         Initial Version  														 **
**********************************************************************************************************************************/

/***************************************************************************
**   DROP TABLE IF AVAILABLE                                             **
***************************************************************************/

DECLARE
BEGIN
     EXECUTE IMMEDIATE 'DROP TABLE EMBT_FCTS_MPWR_HEADER_STG';
EXCEPTION
     WHEN OTHERS THEN
        NULL;
END;
/
/***************************************************************************
**   CREATING TABLE                                                       **
***************************************************************************/
CREATE TABLE EMBT_FCTS_MPWR_HEADER_STG
(
	REC_TYPE              VARCHAR2(2),
	MCO_CONTRACT_NUM      VARCHAR2(5)  ,
	PMT_RCV_DT            DATE  ,
	RPT_RCV_DT            DATE
)
ORGANIZATION EXTERNAL (
TYPE ORACLE_LOADER
DEFAULT DIRECTORY DEV_EXTERNAL
ACCESS PARAMETERS (
RECORDS DELIMITED BY NEWLINE
LOAD WHEN (REC_TYPE = "H")
FIELDS LRTRIM
(
	REC_TYPE			  CHAR(2),
	MCO_CONTRACT_NUM      CHAR(5)	,
	PMT_RCV_DT            CHAR(8) date_format date mask "YYYYMMDD",
	RPT_RCV_DT            CHAR(8) date_format date mask "YYYYMMDD"
)
)
LOCATION ('H3330.MPWRD.R201706.D170601.T1407150')
)
REJECT LIMIT UNLIMITED;
