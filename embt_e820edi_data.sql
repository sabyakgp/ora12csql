DECLARE
     CURSOR
        cur_get_obj
     IS
     SELECT obj.object_name,
            obj.owner,
            obj.object_type
     FROM
          all_objects obj
     WHERE obj.object_name IN ('EMBT_E820EDI_TBL', 'EMBT_E820EDI_DATA')
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
CREATE OR REPLACE TYPE FACETS_CUSTOM.EMBT_E820EDI_DATA
AS 
OBJECT
	(
	INPUT_SUPPL_NBR VARCHAR2(3),
	EMPL_GRP_ID     VARCHAR2(9),
	INVOICE_NBR     VARCHAR2(8),
	ORIGIN_CD       VARCHAR2(2),
	SBS_PRFX        VARCHAR2(1),
	CLM_REF_YY      VARCHAR2(2),
	CLM_REF_JULIAN  VARCHAR2(3),
	CLM_BATCH_NBR   VARCHAR2(6),
	CLM_LINE_NBR    VARCHAR2(2),
	CLM_REF_CHK_DGT VARCHAR2(1),
	CLM_REF_MED_CD  VARCHAR2(1),
	CLM_REF_ADJ_CD  VARCHAR2(1),
	REMT_NBR        VARCHAR2(6),
	INVOICE_TYPE    VARCHAR2(2),
	PROV_CNTL_NBR   VARCHAR2(30),
	RECEPNT_ID      VARCHAR2(11),
	RECEPNT_LNAME   VARCHAR2(17),
	RECEPNT_FNAME   VARCHAR2(10),
	RECEPNT_MID_INT VARCHAR2(1),
	SERVICE_FROM_DT VARCHAR2(8),
	SERVICE_TO_DT   VARCHAR2(8),
	PREM_BILL_AMT   NUMBER(18,9),
	PREM_PAID_AMT   NUMBER(18,9),
	PREM_ADJ_AMT    NUMBER(18,9),
	MED_COVG_DAYS   VARCHAR2(2),
	CHECK_NUMBER    VARCHAR2(15),
	SUPP_REC_IND    VARCHAR2(2),
	BILL_STS	    VARCHAR2(4)
	);
/
--
GRANT EXECUTE ON FACETS_CUSTOM.EMBT_E820EDI_DATA TO FACETS_LOAD,FACETS_CUSTOM;	
/
--
CREATE OR REPLACE TYPE FACETS_CUSTOM.EMBT_E820EDI_TBL IS TABLE OF FACETS_CUSTOM.EMBT_E820EDI_DATA;
/
--
GRANT EXECUTE ON FACETS_CUSTOM.EMBT_E820EDI_TBL TO FACETS_LOAD,FACETS_CUSTOM;
/