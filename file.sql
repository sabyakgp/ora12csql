DECLARE
	RECORD varchar2(32767);
	FILE_TYPE UTL_FILE.FILE_TYPE;
	TYPE E820EDI_Type IS RECORD 
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
		INVOICE_TYPE    VARCHAR2(2) := '21',
		PROV_CNTL_NBR   VARCHAR2(30),
		RECEPNT_ID      VARCHAR2(11),
		RECEPNT_LNAME   VARCHAR2(17),
		RECEPNT_FNAME   VARCHAR2(10),
		RECEPNT_MID_INT VARCHAR2(1),
		SERVICE_FROM_DT VARCHAR2(8),
		SERVICE_TO_DT   VARCHAR2(8),
		PREM_BILL_AMT   NUMBER(18,9),
		PREM_PAID_AMT   NUMBER(18,0),
		PREM_ADJ_AMT    NUMBER(18,9),
		MED_COVG_DAYS   VARCHAR2(2) := '00',
		CHECK_NUMBER    VARCHAR2(15),
		SUPP_REC_IND    VARCHAR2(2)
		);
	TYPE PYMNT_TBL IS TABLE OF E820EDI_Type;
    PYMNT_RECORD PYMNT_TBL := PYMNT_TBL(); 
	E820PYMNT_REC E820EDI_Type;
	I NUMBER := 1;
	l_segment 			VARCHAR2(3);
	l_interchange_recv_id VARCHAR2(3);
    l_remit_nbr         VARCHAR2(6);
	l_id_qualifier      VARCHAR2(2); 
	l_id_code           VARCHAR2(20);

BEGIN
	FILE_TYPE := UTL_FILE.FOPEN('DEV_EXTERNAL', 'R170828070447.2086.820.0000_4342', 'R');
	
	BEGIN
	LOOP
		UTL_FILE.GET_LINE(FILE_TYPE, RECORD);

		l_segment := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,1,'i',2);

		CASE l_segment
			WHEN 'ISA'
				THEN 
					l_interchange_recv_id := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,8,'i',2));
					IF l_interchange_recv_id = '885' THEN 
						E820PYMNT_REC.INPUT_SUPPL_NBR := TRIM(l_interchange_recv_id);
					ELSE
					    E820PYMNT_REC.INPUT_SUPPL_NBR := SUBSTR(TRIM(l_interchange_recv_id),2,3);
				  	END IF;
		 	WHEN 'BPR'
				THEN
					l_remit_nbr := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,17,'i',2), 3,6);
					E820PYMNT_REC.REMT_NBR := l_remit_nbr;
		    WHEN 'ENT'
				THEN
					l_id_qualifier := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2)
					IF l_id_qualifier = '2J' THEN
					   IF l_interchange_recv_id = '885' THEN
						  l_id_code := REGEXP_REPLACE(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2)),'^HH|RP','000',1,1);
						  E820PYMNT_REC.EMPL_GRP_ID := SUBSTR(l_id_code, 1, 9);
						  E820PYMNT_REC.INVOICE_NBR := SUBSTR(l_id_code, 10,8);
						  E820PYMNT_REC.ORIGIN_CD :=   SUBSTR(l_id_code, 19,2);
						  E820PYMNT_REC.PROV_CNTL_NBR := REGEXP_REPLACE(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2)),'^HH|RP','00',1,1);
			      	   END IF;
				    END IF;
			WHEN 'RMR'
				THEN
					IF l_interchange_recv_id = '885' THEN 
						IF REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,2,'i',2) = 'IK' THEN 
							E820PYMNT_REC.CLM_REF_YY := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2), 1,2);
							E820PYMNT_REC.CLM_REF_JULIAN := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2), 3,3);
							E820PYMNT_REC.CLM_BATCH_NBR := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2), 6,6);
						    E820PYMNT_REC.CLM_LINE_NBR := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2), 12,2);
							E820PYMNT_REC.CLM_REF_CHK_DGT := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2), 14,1);
							E820PYMNT_REC.CLM_REF_MED_CD := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2), 15,1);
							E820PYMNT_REC.CLM_REF_ADJ_CD := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*]*)',1,3,'i',2), 16,1);

			WHEN 'NM1'
				THEN
					E820PYMNT_REC.RECEPNT_ID :=  REGEXP_SUBSTR(RECORD, '[^*|~]+',1,10);
			ELSE
				NULL;
		END CASE;
		
     	
		PYMNT_RECORD.EXTEND;
		PYMNT_RECORD(I) := E820PYMNT_REC;

	END LOOP;

		UTL_FILE.FCLOSE(FILE_TYPE);

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END;
	
--	FOR I IN PYMNT_RECORD.FIRST .. PYMNT_RECORD.LAST 

--		LOOP
--			DBMS_OUTPUT.PUT_LINE('Input Supplement Number: ' || PYMNT_RECORD(I).INPUT_SUPPL_NBR);
--			DBMS_OUTPUT.PUT_LINE('Remittance Number: ' || PYMNT_RECORD(I).REMT_NBR);
--			DBMS_OUTPUT.PUT_LINE('Recepient ID: ' || PYMNT_RECORD(I).RECEPNT_ID);
--			DBMS_OUTPUT.PUT_LINE('Employee Group ID: ' || PYMNT_RECORD(I).EMPL_GRP_ID);
--
--		END LOOP;

END;
/
