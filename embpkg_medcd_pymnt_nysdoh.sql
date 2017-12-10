SET SERVEROUTPUT ON;
SET DEFINE OFF;
CREATE OR REPLACE PACKAGE FACETS_CUSTOM.EMBPKG_MEDCD_PYMNT_NYSDOH
AS

  /* ***********************************************************************************************************************
  ** Object Name       : EMBPKG_MEDCD_PYMNT_NYSDOH                                                                      **
  ** Prepared by       : Cognizant offshore                                                                             **
  ** Prepared Date     : 09/24/2016                                                                                     **
  ** Purpose           : The Package will contain all stored procedure/functions required to process State (NYSDOH)     **
  **                     payment for Medicaid members and generate reports for Emblem Treasury and Billing Departments  **
  **                     This package will cover the following functionalities related to Medicaid						**
  **																													**
  **					 1. Loading EDI 820 file from NYSDOH into Stage													**
  **					 2. Loading 820S supplementary file from NYSDOH ito Stage										**
  **					 3. Generating Bill Remittance History Report for EH Treasury									**
  **					 4. Generating CSV Report for EH Treasury														**	
  ** Dependencies      :																								**                                                **
  **    a. Tables      :                                                                                                **
  **					 1. EMBT_FCTS_820_STG                                                                     		**
  **    b. Procedures:                                                                                                	**
  **           1. EMBP_MEDCD_EDI820_LOAD                                                                         		**
  **  Input  Parameters : NO                                                                                            **
  **  Output Parameters :                                                                                               **
  ** Version History   :                                                                                                **
  ** Version Date           Developer                  			Description                                             **
  ** ------- -----------    -----------------------    			----------------------------------------                **
  **  1.0    07/06/2016     Sabyasachi Mitra               		Initial Version                                     	**
  ***********************************************************************************************************************/

	
    PROCEDURE EMBP_MEDCD_EDI820_LOAD;
	
	FUNCTION EMBF_READ_EDI820 
	  RETURN
	EMBT_E820EDI_TBL PIPELINED;
	
	FUNCTION EMBF_OPEN_EDI820 (l_filename VARCHAR2, l_mode VARCHAR2)
	  RETURN
	VARCHAR2;
	 
	FUNCTION EMBF_CLOSE_EDI820 
	  RETURN
	VARCHAR2;
	

END EMBPKG_MEDCD_PYMNT_NYSDOH;
/
CREATE OR REPLACE PACKAGE BODY FACETS_CUSTOM.EMBPKG_MEDCD_PYMNT_NYSDOH
AS
  /* ***********************************************************************************************************************
  ** Version History   :                                                                                                  **
  ** Version Date           Developer                     Description                                                     **
  ** ------- -----------    -----------------------       ----------------------------------------                        **
  **  1.0    09/24/2016     Cognizant Offshore                    Initial Version                                         **
  *************************************************************************************************************************/
  
  --FILE_TYPE UTL_FILE.FILE_TYPE;
  
  l_File_Name VARCHAR2(128);
  l_File_Sts  VARCHAR2(2);
  l_Read_Mode VARCHAR2(1);
  l_File_Handle UTL_FILE.FILE_TYPE;
  
  
  FUNCTION EMBF_OPEN_EDI820 
					(
						l_filename VARCHAR2, 
						l_mode VARCHAR2
					)
	RETURN VARCHAR2
  IS
  /* **********************************************************************************************************************
    ** Prepared by       : Cognizant offshore                                                                              **
    ** Prepared Date     : 09/24/2016                                                                                      **
    ** Description       : Read, EDI 820 file  		   																	   **
    ** Version History   :                                                                                                 **
    ** Version Date           Developer                  Description                                                       **
    ** ------- -----------    -----------------------    ----------------------------------------                          **
    **  1.0    09/24/2016     Cognizant                   Initial Version                                                  **
	************************************************************************************************************************/
  l_Return_Code VARCHAR2(2);
  BEGIN
  
	--FILE_TYPE := UTL_FILE.FOPEN('EMB_FACETSSI_DIR', 'R170828070447.2086.820.0000_4342', 'R');
	   l_Return_Code := 'OK';
	   l_File_Handle := UTL_FILE.FOPEN('EMB_FACETSSI_DIR', l_filename, l_mode);

	  RETURN l_Return_Code;
  
 END EMBF_OPEN_EDI820;
	
 FUNCTION EMBF_CLOSE_EDI820 
 	RETURN VARCHAR2
 IS
	l_Return_Code VARCHAR2(2);
 BEGIN
	
	UTL_FILE.FCLOSE(l_File_Handle);
	
	l_Return_Code := 'OK';
	
	RETURN l_Return_Code;
	
 END EMBF_CLOSE_EDI820;
  
 FUNCTION EMBF_READ_EDI820 
	RETURN EMBT_E820EDI_TBL PIPELINED
  IS
  /* **********************************************************************************************************************
    ** Prepared by       : Cognizant offshore                                                                              **
    ** Prepared Date     : 09/24/2016                                                                                      **
    ** Description       : Read, parse and load EDI 820 file format into Facets Stage table for further processing 		   **
    ** Version History   :                                                                                                 **
    ** Version Date           Developer                  Description                                                       **
    ** ------- -----------    -----------------------    ----------------------------------------                          **
    **  1.0    09/24/2016     Cognizant                   Initial Version                                                  **
	************************************************************************************************************************/
	RECORD varchar2(200);
	
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
		PREM_PAID_AMT   NUMBER(18,9),
		PREM_ADJ_AMT    NUMBER(18,9),
		MED_COVG_DAYS   VARCHAR2(2) := '00',
		CHECK_NUMBER    VARCHAR2(15),
		SUPP_REC_IND    VARCHAR2(2),
		BILL_STS	    VARCHAR2(4)
		);
	E820PYMNT_REC E820EDI_Type;
	I NUMBER(10) := 1;
	
	l_Segment 			VARCHAR2(3);
	l_Input_Suppl_Num	VARCHAR2(3);
    l_Remit_Nbr         VARCHAR2(6);
	l_Patnt_Cntl_Nbr    VARCHAR2(20); 
	l_Enty_Id_Code		VARCHAR2(2);
	l_id_code           VARCHAR2(20);
	pv_SpErrorMsg    	VARCHAR2(1000);
	l_Prem_Bill         NUMBER(18,9);
	l_Prem_Paid         NUMBER(18,9);
	l_Prem_Adj          NUMBER(18,9);
	l_Eh_Grp_prfx		VARCHAR2(2);
	l_Error_Msg         VARCHAR2(50);
  
  BEGIN
	
--	IF l_File_Handle IS NULL THEN 
--		RAISE_APPLICATION_ERROR (-2001, l_Error_Msg, TRUE);
--	END IF;
	
	UTL_FILE.GET_LINE(l_File_Handle, RECORD);

	LOOP
	
		l_Segment := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,1,'i',2));
				
		EXIT WHEN l_Segment = 'SE';

		CASE 
			WHEN l_Segment = 'ISA'
				THEN 
					l_Input_Suppl_Num := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,9,'i',2));

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
					   l_Eh_Grp_prfx := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2), 1, 2);
					   IF l_Input_Suppl_Num = '885' AND l_Eh_Grp_prfx IN ('HH', 'RP')
						THEN
						  UTL_FILE.GET_LINE(l_File_Handle, RECORD);
						  CONTINUE;
					   ELSIF l_Input_Suppl_Num = '885'  
						THEN
						  l_Patnt_Cntl_Nbr := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2);
						  E820PYMNT_REC.EMPL_GRP_ID := SUBSTR(l_Patnt_Cntl_Nbr, 1, 9);
						  E820PYMNT_REC.INVOICE_NBR := SUBSTR(l_Patnt_Cntl_Nbr, 10,8);
						  E820PYMNT_REC.ORIGIN_CD 	:= SUBSTR(l_Patnt_Cntl_Nbr, 18,2);
						  E820PYMNT_REC.SBS_PRFX 	:= SUBSTR(l_Patnt_Cntl_Nbr, 20,1);
						  E820PYMNT_REC.PROV_CNTL_NBR := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2);
					   END IF;
			
			WHEN l_Segment = 'NM1'
				THEN
					IF l_Input_Suppl_Num = '885' AND l_Eh_Grp_prfx IN ('HH', 'RP')
						THEN 
						UTL_FILE.GET_LINE(l_File_Handle, RECORD);
						CONTINUE;
					ELSIF l_Input_Suppl_Num = '885'
						THEN 
						E820PYMNT_REC.RECEPNT_ID 	:=  REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,10,'i',2);
						E820PYMNT_REC.RECEPNT_LNAME :=  REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,4,'i',2);
						E820PYMNT_REC.RECEPNT_FNAME :=  REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2);
						E820PYMNT_REC.RECEPNT_MID_INT := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,6,'i',2);
					END IF;
					
			WHEN l_Segment = 'RMR'
				THEN
					IF l_Input_Suppl_Num = '885' AND l_Eh_Grp_prfx IN ('HH', 'RP')
						THEN 
						UTL_FILE.GET_LINE(l_File_Handle, RECORD);
						CONTINUE;
					ELSIF l_Input_Suppl_Num = '885'
						THEN	
						E820PYMNT_REC.CLM_REF_YY 	 := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 1,2);
						E820PYMNT_REC.CLM_REF_JULIAN := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 3,3);
						E820PYMNT_REC.CLM_BATCH_NBR  := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 6,6);
						E820PYMNT_REC.CLM_LINE_NBR 	 := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 12,2);
						E820PYMNT_REC.CLM_REF_CHK_DGT := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 14,1);
						E820PYMNT_REC.CLM_REF_MED_CD := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 15,1);
						E820PYMNT_REC.CLM_REF_ADJ_CD := SUBSTR(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2), 16,1);
						
						E820PYMNT_REC.PREM_BILL_AMT := NVL(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,6,'i',2), 0);
						E820PYMNT_REC.PREM_PAID_AMT := NVL(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,5,'i',2), 0);
						
						E820PYMNT_REC.PREM_ADJ_AMT := 0;
						E820PYMNT_REC.SUPP_REC_IND := NULL;
						
						UTL_FILE.GET_LINE(l_File_Handle, RECORD);
						l_Segment := TRIM(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,1,'i',2));

						IF l_Segment = 'ADX' THEN 
							E820PYMNT_REC.PREM_ADJ_AMT := NVL(REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,2,'i',2),0);
							E820PYMNT_REC.SUPP_REC_IND := REGEXP_SUBSTR(RECORD, '(^|\*)([^\*|~]*)',1,3,'i',2);	
						END IF;	
						
						IF E820PYMNT_REC.PREM_BILL_AMT > 0 AND E820PYMNT_REC.PREM_PAID_AMT > 0 AND l_Segment <> 'ADX'
						THEN 
							E820PYMNT_REC.BILL_STS := 'PAID';
						ELSIF E820PYMNT_REC.PREM_PAID_AMT > 0 AND E820PYMNT_REC.PREM_BILL_AMT >= 0  
							THEN
							IF l_Segment = 'ADX' THEN
								IF E820PYMNT_REC.PREM_ADJ_AMT <> 0 THEN 
									E820PYMNT_REC.BILL_STS := 'ADJ';
								ELSIF E820PYMNT_REC.PREM_BILL_AMT > 0 THEN
									E820PYMNT_REC.BILL_STS := 'DENY';
								END IF;
							ELSIF E820PYMNT_REC.PREM_BILL_AMT > 0 THEN 
								E820PYMNT_REC.BILL_STS := 'DENY';
							END IF;
						ELSIF (
							(E820PYMNT_REC.PREM_PAID_AMT < 0 AND E820PYMNT_REC.PREM_BILL_AMT < 0) OR
							(E820PYMNT_REC.PREM_PAID_AMT = 0 AND E820PYMNT_REC.PREM_BILL_AMT > 0  AND E820PYMNT_REC.CLM_REF_ADJ_CD = '1') OR
							(E820PYMNT_REC.PREM_PAID_AMT < 0 AND E820PYMNT_REC.PREM_BILL_AMT = 0)
							  )
						THEN 
							E820PYMNT_REC.BILL_STS := 'VOID';
						ELSE
							E820PYMNT_REC.BILL_STS := 'ERR';
						END IF;
						
						E820PYMNT_REC.INPUT_SUPPL_NBR := TRIM(l_Input_Suppl_Num);
						E820PYMNT_REC.REMT_NBR := l_Remit_Nbr;
						E820PYMNT_REC.CHECK_NUMBER :=  '999999999999999';

						PIPE ROW (
									FACETS_CUSTOM.EMBT_E820EDI_DATA(E820PYMNT_REC.INPUT_SUPPL_NBR, E820PYMNT_REC.EMPL_GRP_ID, E820PYMNT_REC.INVOICE_NBR, 
																       E820PYMNT_REC.ORIGIN_CD, E820PYMNT_REC.SBS_PRFX, E820PYMNT_REC.CLM_REF_YY, E820PYMNT_REC.CLM_REF_JULIAN,
																	   E820PYMNT_REC.CLM_BATCH_NBR, E820PYMNT_REC.CLM_LINE_NBR, E820PYMNT_REC.CLM_REF_CHK_DGT, 
																	   E820PYMNT_REC.CLM_REF_MED_CD, E820PYMNT_REC.CLM_REF_ADJ_CD, E820PYMNT_REC.REMT_NBR,
																	   E820PYMNT_REC.INVOICE_TYPE, E820PYMNT_REC.PROV_CNTL_NBR, E820PYMNT_REC.RECEPNT_ID,
																	   E820PYMNT_REC.RECEPNT_LNAME, E820PYMNT_REC.RECEPNT_FNAME, E820PYMNT_REC.RECEPNT_MID_INT,
																	   E820PYMNT_REC.SERVICE_FROM_DT, E820PYMNT_REC.SERVICE_TO_DT, E820PYMNT_REC.PREM_BILL_AMT,
																	   E820PYMNT_REC.PREM_PAID_AMT, E820PYMNT_REC.PREM_ADJ_AMT, E820PYMNT_REC.MED_COVG_DAYS,
																	   E820PYMNT_REC.CHECK_NUMBER, E820PYMNT_REC.SUPP_REC_IND, E820PYMNT_REC.BILL_STS
																	)
								);
					END IF;
			ELSE
				NULL;
				
		END CASE;
	
		UTL_FILE.GET_LINE(l_File_Handle, RECORD);
		
	END LOOP;

  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;

  END EMBF_READ_EDI820;
  
  PROCEDURE EMBP_MEDCD_EDI820_LOAD
  AS
  /* **********************************************************************************************************************
    ** Prepared by       : Cognizant offshore                                                                              **
    ** Prepared Date     : 09/24/2016                                                                                      **
    ** Description       : Read, parse and load EDI 820 file format into Facets Stage table for further processing 		   **
    ** Version History   :                                                                                                 **
    ** Version Date           Developer                  Description                                                       **
    ** ------- -----------    -----------------------    ----------------------------------------                          **
    **  1.0    09/24/2016     Cognizant                   Initial Version                                                  **
	************************************************************************************************************************/
  l_Trunc_Sts      VARCHAR2(1000);
  l_Error_Msg      VARCHAR2(100);
  l_Stored_Proc_Name VARCHAR2(128) := 'EMBP_MEDCD_EDI820_LOAD';
  l_Table_name     VARCHAR2(128) := 'EMBT_FCTS_820_STG';
  l_filename       VARCHAR2(100);
  l_mode           VARCHAR2(1);
  l_Return_code    VARCHAR2(2);
  
  BEGIN
	
	FACETS_STAGE.EMBP_PCKG_INTF_COMMON.EMBP_TRUNCATE_TBL('FACETS_STAGE', 'EMBT_FCTS_820_STG', l_Trunc_Sts);
	
	IF l_Trunc_sts <> 'Successful' THEN
	    l_Error_Msg := 'Stored Procedure: ' || l_Stored_Proc_Name || ' failed while truncating ' || l_Table_name;
		RAISE_APPLICATION_ERROR('-20001',l_Error_Msg, TRUE);
	END IF;
	
	l_filename := 'R170828070447.2086.820.0000_4342';
	l_mode := 'R';

	l_Return_code := EMBF_OPEN_EDI820(l_filename, l_mode);
	
	IF l_Return_code <> 'OK' THEN
		l_Error_Msg := 'Funtion EMBF_OPEN_EDI820 in ' || l_Stored_Proc_Name || ' failed while opening ' || l_filename;
		RAISE_APPLICATION_ERROR(-2001, l_Error_Msg, True);
	END IF;
	
	INSERT 
		INTO
	FACETS_STAGE.EMBT_FCTS_820_STG
	SELECT 
		* 
	FROM 
		TABLE(EMBF_READ_EDI820());

	COMMIT;
	
	l_Return_code := EMBF_CLOSE_EDI820();
  
  EXCEPTION
	WHEN OTHERS THEN
		l_Error_Msg := 'Stored Procedure: ' || l_Stored_Proc_Name || ' failed';
		RAISE_APPLICATION_ERROR('-20001',l_Error_Msg, TRUE);
		
  END EMBP_MEDCD_EDI820_LOAD;
END EMBPKG_MEDCD_PYMNT_NYSDOH;
/
SHOW ERROR
GRANT EXECUTE ON FACETS_CUSTOM.EMBPKG_MEDCD_PYMNT_NYSDOH TO FACETS_LOAD;