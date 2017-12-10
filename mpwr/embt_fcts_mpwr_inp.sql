/**********************************************************************************************************************************
** Table Name     : EMBT_FCTS_MPWR_INP                                                                                           **
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
     WHERE obj.object_name = 'EMBT_FCTS_MPWR_INP'
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

CREATE TABLE FACETS_STAGE.EMBT_FCTS_MPWR_INP
(
	MCO_CONTRACT_NUM			VARCHAR2(5),
	PMT_RCV_DT					VARCHAR2(8),
	RPT_RCV_DT					VARCHAR2(8),
	PLAN_BNFT_ID				VARCHAR2(3),
	PLAN_SEG_ID					VARCHAR2(3),
	HIC_NUM						VARCHAR2(12),
	SURNAME						VARCHAR2(7),
	FIRST_INITIAL				VARCHAR2(1),
	SEX							VARCHAR2(1),
	DATE_OF_BIRTH				VARCHAR2(8),
	PREM_PMT_OPT				VARCHAR2(3),
	PREM_START_DT				VARCHAR2(8),
	PREM_END_DT					VARCHAR2(8),
	MONTH_NUM					VARCHAR2(2),
	PREM_AMT_C					NUMBER(18,4),
	PREM_AMT_D					NUMBER(18,4),
	PENL_AMT_D					NUMBER(18,4)
);
/***************************************************************************
**   GRANTS FOR THE ABOVE TABLE                                          **
***************************************************************************/

GRANT
SELECT,
INSERT,
UPDATE,
DELETE ON FACETS_STAGE.EMBT_FCTS_MPWR_INP TO FACETS_CUSTOM,FACETS_LOAD,DEVELOPER;