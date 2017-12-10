/* *********************************************************************************************************************************
** Table Name     : EMBT_FCTS_820S_HIST                                                                                          **
** Purpose        : External table required to load 820S input file.                                                             **
** Version Number : 1.0                                                                                                          **
** Version   Date           Developer                   Description                                                              **
** --------  -----------    --------------------        ------------------------                                                 **
** 1.0       09/19/2017       Cognizant Offshore         Initial Version  														 **
**********************************************************************************************************************************/

/* **************************************************************************
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
     WHERE obj.object_name = 'EMBT_FCTS_820S_HIST'
     AND   obj.owner       = 'FACETS_CUSTOM';
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
CREATE TABLE FACETS_CUSTOM.EMBT_FCTS_820_HIST
(
		RECEIVER_ID			VARCHAR2(4),  
		COUNTY_ID1			VARCHAR2(8),
		COUNTY_ID2			VARCHAR2(8),
		LOCATOR_CD			VARCHAR2(3),
		BILL_STATUS			VARCHAR2(4),
		GRGR_SGSG 			VARCHAR2(20),
		CRN_DATA			VARCHAR2(16),
		REMIT_DATE    		DATE,
		REMIT_SEQ_NUMBER    VARCHAR2(6),
		INV_TYPE			VARCHAR2(2),
		PROV_CTRL_NUM		VARCHAR2(30),
		PYMT_DATE			DATE,
		PYMT_DUE_DATE		DATE,
		MEDCD_NO			VARCHAR2(11),
		MEMBER_LAST_NAME	VARCHAR2(17),
		MEMBER_FIRST_NAME	VARCHAR2(10),
		MEMBER_MID_INIT	    VARCHAR2(1),
		BILL_PERIOD_FROM_DT	DATE,
		BILL_PERIOD_THRU_DT	DATE,
		NCPDP_CD			VARCHAR2(11),
		PROC_RATE_CD		NUMBER(4),
		TIMES_PERFORMED		NUMBER(12,4),
		AMT_BILLED			NUMBER(12,4),
		AMT_PAID			NUMBER(12,4),
		AMT_ADJ				NUMBER(12,4),
		MED_COVG_DAYS		NUMBER(4),
		ERR_CD1				VARCHAR2(5),
		ERR_CD2				VARCHAR2(5),
		CHECK_NUM			VARCHAR2(15)
);
/***************************************************************************
**   GRANTS FOR THE ABOVE TABLE                                          **
***************************************************************************/
GRANT
SELECT,
INSERT,
UPDATE,
DELETE ON FACETS_CUSTOM.EMBT_FCTS_820_HIST TO FACETS_LOAD,DEVELOPER;