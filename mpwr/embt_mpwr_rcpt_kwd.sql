/**********************************************************************************************************************************
** Table Name     : EMBT_FCTS_MPWR_RCPT_KWD                                                                                    **
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
     WHERE obj.object_name = 'EMBT_MPWR_RCPT_KWD'
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

CREATE TABLE FACETS_STAGE.EMBT_MPWR_RCPT_KWD
(
	KWD_GRGR_ID				VARCHAR2(8),
	KWD_SBSB_ID				VARCHAR2(9),
	KWD_RCPT_PAY_METH		VARCHAR2(1),
	KWD_RCPT_MCTR_RSN		VARCHAR2(1),
	KWD_RCPT_RCVD_DT		TIMESTAMP(6),
	KWD_RCPT_CD				VARCHAR2(1),
	KWD_RCPT_AMT			NUMBER(18,4),
	KWD_RCPT_CLASS			VARCHAR(50)	
);
/***************************************************************************
**   GRANTS FOR THE ABOVE TABLE                                          **
***************************************************************************/

GRANT
SELECT,
INSERT,
UPDATE,
DELETE ON FACETS_STAGE.EMBT_MPWR_RCPT_KWD TO FACETS_CUSTOM,FACETS_LOAD,DEVELOPER;