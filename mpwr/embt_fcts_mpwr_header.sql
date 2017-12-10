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
     CURSOR
        cur_get_obj
     IS
     SELECT obj.object_name,
            obj.owner,
            obj.object_type
     FROM
          all_objects obj
     WHERE obj.object_name = 'EMBT_FCTS_MPWR_HEADER_STG'
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
CREATE TABLE FACETS_STAGE.EMBT_FCTS_MPWR_HEADER_STG
(
	REC_TYPE              VARCHAR2(2),
	MCO_CONTRACT_NUM      VARCHAR2(5)  ,
	PMT_RCV_DT            DATE  ,
	RPT_RCV_DT            DATE
)
ORGANIZATION EXTERNAL (
TYPE ORACLE_LOADER
DEFAULT DIRECTORY EMB_FACETSSI_DIR
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
LOCATION ('embf_fcts_mpwr.txt')
)
REJECT LIMIT UNLIMITED;

/***************************************************************************
**   GRANTS FOR THE ABOVE TABLE                                          **
***************************************************************************/

GRANT
SELECT
ON FACETS_STAGE.EMBT_FCTS_MPWR_HEADER_STG TO FACETS_CUSTOM,FACETS_LOAD, DEVELOPER;