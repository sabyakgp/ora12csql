DECLARE
	RECORD varchar2(200);
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
		PREM_PAID_AMT   VARCHAR2(20),
		PREM_ADJ_AMT    VARCHAR2(20),
		MED_COVG_DAYS   VARCHAR2(2) := '00',
		CHECK_NUMBER    VARCHAR2(15),
		SUPP_REC_IND    VARCHAR2(2),
		BILL_STS	    VARCHAR2(4)
		);
	TYPE PYMNT_TBL IS TABLE OF E820EDI_Type;
    PYMNT_RECORD PYMNT_TBL := PYMNT_TBL(); 
	E820PYMNT_REC E820EDI_Type;
	I NUMBER(10) := 1;
	
	l_Segment 			VARCHAR2(3);
	l_Input_Suppl_Num	VARCHAR2(3);
    l_Remit_Nbr         VARCHAR2(6);
	l_Patnt_Cntl_Nbr    VARCHAR2(20); 
	l_Enty_Id_Code		VARCHAR2(2);
	l_id_code           VARCHAR2(20);
	pv_SpErrorMsg    	VARCHAR2(1000);
	

BEGIN
	FILE_TYPE := UTL_FILE.FOPEN('DEV_EXTERNAL', 'R170828070447.2086.820.0000_4342', 'R');
	
	UTL_FILE.GET_LINE(FILE_TYPE, RECORD);
	
	LOOP
	
		l_Segment := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,1,'i',2));
		
--		DBMS_OUTPUT.PUT_LINE(RECORD);
--		DBMS_OUTPUT.PUT_LINE(l_Segment);
		
		EXIT WHEN l_Segment = 'SE';

		CASE 
			WHEN l_Segment = 'ISA'
				THEN 
					l_Input_Suppl_Num := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,9,'i',2));
					DBMS_OUTPUT.PUT_LINE(l_Input_Suppl_Num);
					IF l_Input_Suppl_Num = '885' THEN 
						E820PYMNT_REC.INPUT_SUPPL_NBR := TRIM(l_Input_Suppl_Num);
					ELSE
					    E820PYMNT_REC.INPUT_SUPPL_NBR := SUBSTR(TRIM(l_Input_Suppl_Num),2,3);
				  	END IF;
		 	WHEN l_Segment = 'BPR' 
				THEN
					l_Remit_Nbr := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,17,'i',2), 3,6);
					E820PYMNT_REC.REMT_NBR := l_Remit_Nbr;
					
			WHEN l_Segment = 'TRN'
				THEN 
					IF (
						(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2) =  'NOPAYMENT') OR 
					    (REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2) =  'NO PAYMENT')
					   ) 
					THEN 						
						E820PYMNT_REC.CHECK_NUMBER :=  '999999999999999';
					END IF;
			
			WHEN l_Segment IN ('GS', 'ST', 'N1') 
				THEN	
					NULL;
			
			WHEN l_Segment = 'ENT'
				THEN
					l_Enty_Id_Code := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2);
--					IF l_Enty_Id_Code = '2J' THEN
					   IF l_Input_Suppl_Num = '885' THEN
						  l_Patnt_Cntl_Nbr := REGEXP_REPLACE(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2),'^HH|RP','000',1,1);
						  E820PYMNT_REC.EMPL_GRP_ID := SUBSTR(l_Patnt_Cntl_Nbr, 1, 9);
						  E820PYMNT_REC.INVOICE_NBR := SUBSTR(l_Patnt_Cntl_Nbr, 10,8);
						  E820PYMNT_REC.ORIGIN_CD 	:= SUBSTR(l_Patnt_Cntl_Nbr, 19,2);
						  E820PYMNT_REC.PROV_CNTL_NBR := REGEXP_REPLACE(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2),'^HH|RP','00',1,1);
					   END IF;
--					END IF;
					IF REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2) = '999999999' THEN
						DBMS_OUTPUT.PUT_LINE(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2));
						DBMS_OUTPUT.PUT_LINE(I);
					END IF;
			
			WHEN l_Segment = 'NM1'
				THEN
					E820PYMNT_REC.RECEPNT_ID 	:=  REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,10,'i',2);
					E820PYMNT_REC.RECEPNT_LNAME :=  REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,4,'i',2);
					E820PYMNT_REC.RECEPNT_FNAME :=  REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2);
					E820PYMNT_REC.RECEPNT_MID_INT := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,6,'i',2);
			
		--			UTL_FILE.GET_LINE(FILE_TYPE, RECORD);
	    --			l_Segment := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,1,'i',2));

					--IF l_Segment = 'ENT' THEN
				--		DBMS_OUTPUT.PUT_LINE('Again ENT!');
			--			CONTINUE;
		--			END IF;
					
			WHEN l_Segment = 'RMR'
				THEN
--					DBMS_OUTPUT.PUT_LINE(l_Segment);
					IF l_Input_Suppl_Num = '885' THEN 
						E820PYMNT_REC.CLM_REF_YY 	 := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 1,2);
						E820PYMNT_REC.CLM_REF_JULIAN := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 3,3);
						E820PYMNT_REC.CLM_BATCH_NBR  := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 6,6);
						E820PYMNT_REC.CLM_LINE_NBR 	 := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 12,2);
						E820PYMNT_REC.CLM_REF_CHK_DGT := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 14,1);
						E820PYMNT_REC.CLM_REF_MED_CD := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 15,1);
						E820PYMNT_REC.CLM_REF_ADJ_CD := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 16,1);
					END IF;
					
						E820PYMNT_REC.PREM_BILL_AMT := RTRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,6,'i',2), '~');
						E820PYMNT_REC.PREM_PAID_AMT := RTRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2), '~');
					
                   	--DBMS_OUTPUT.PUT_LINE(E820PYMNT_REC.RECEPNT_ID);
					UTL_FILE.GET_LINE(FILE_TYPE, RECORD);
					l_Segment := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,1,'i',2));
					
					IF (l_Segment = 'ENT' OR l_Segment = 'SE') THEN 
						E820PYMNT_REC.INPUT_SUPPL_NBR := TRIM(l_Input_Suppl_Num);
						E820PYMNT_REC.REMT_NBR := l_Remit_Nbr;
						E820PYMNT_REC.CHECK_NUMBER :=  '999999999999999';
						IF (E820PYMNT_REC.PREM_PAID_AMT > 0 AND E820PYMNT_REC.PREM_BILL_AMT >= 0)
							THEN 
							E820PYMNT_REC.BILL_STS := 'PAID';
						END IF; 
							
						PYMNT_RECORD.EXTEND;
						PYMNT_RECORD(I) := E820PYMNT_REC;
						I := I + 1;
						CONTINUE;
					ELSIF l_Segment = 'ADX' THEN 
						CONTINUE;
					END IF;				
					
			WHEN l_Segment = 'ADX'
				THEN 

--					DBMS_OUTPUT.PUT_LINE(l_Segment);
					E820PYMNT_REC.PREM_ADJ_AMT := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,2,'i',2);
					E820PYMNT_REC.SUPP_REC_IND := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2);
					UTL_FILE.GET_LINE(FILE_TYPE, RECORD);
					l_Segment := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,1,'i',2));

					IF (l_Segment = 'ENT' OR l_Segment = 'SE') THEN 
						E820PYMNT_REC.INPUT_SUPPL_NBR := TRIM(l_Input_Suppl_Num);
						E820PYMNT_REC.REMT_NBR := l_Remit_Nbr;
						E820PYMNT_REC.CHECK_NUMBER :=  '999999999999999';
						IF (E820PYMNT_REC.PREM_PAID_AMT > 0 AND E820PYMNT_REC.PREM_BILL_AMT >= 0 AND E820PYMNT_REC.PREM_ADJ_AMT <> 0) 
							THEN 
								E820PYMNT_REC.BILL_STS := 'ADJ';
						END IF;
								
						
						PYMNT_RECORD.EXTEND;
						PYMNT_RECORD(I) := E820PYMNT_REC;
					
						I := I + 1;
						CONTINUE;
					
					ELSE
						IF l_Segment <> 'SE' THEN
							pv_SpErrorMsg := 'Expecting ENT, received something else. Please check the file validity.';
							RAISE_APPLICATION_ERROR('-20001',pv_SpErrorMsg, TRUE);
						END IF;
					END IF;
			ELSE
				NULL;
				
		END CASE;

		UTL_FILE.GET_LINE(FILE_TYPE, RECORD);
		
	END LOOP;

	UTL_FILE.FCLOSE(FILE_TYPE);
	DBMS_OUTPUT.PUT_LINE('Total number of records: ' || PYMNT_RECORD.COUNT);

	FOR I IN PYMNT_RECORD.FIRST .. PYMNT_RECORD.LAST 

		LOOP
			DBMS_OUTPUT.PUT_LINE('Medicaid NBR: ' || PYMNT_RECORD(I).RECEPNT_ID || ' ' || PYMNT_RECORD(I).EMPL_GRP_ID || ' ' || E820PYMNT_REC.BILL_STS);

	END LOOP;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;

	
END;
/
