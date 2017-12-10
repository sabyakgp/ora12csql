SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE FACETS_CUSTOM.EMBPKG_FCTS_MPWR_INT
AS
/* ***********************************************************************************************************************
  ** OBJECT NAME       : EMBPKG_FCTS_MPWR_INT                                                                           **
  ** PREPARED BY       : COGNIZANT OFFSHORE                                                                             **
  ** PREPARED DATE     : 07/10/2017                                                                                     **
  ** PURPOSE           : THIS WILL VALIDATE AND LOAD THE IDP LOCKBOX FILES TO STAGE TABLES TO PREPARE         			**
  **                     KEYWORD FILE.                                                                                  **
  ** DEPENDENCIES      :																								**
  **    A. TABLES      :                                                                                                **
  **                     1. EMBT_BNKFCTS_LCKBX_DTL                                                                      **
  **                     2. EMBT_BNKFCTS_ERROR                                                                          **
  **                     3. EMBT_BNKFCTS_LCKBX_ERR                                                                      **
  **                     4. EMBT_BNKFCTS_LCKBX_KWD                                                                     	**
  **    B. PROCEDURES:                                                                                                  **
  **           1. EMBP_BNKFCTS_LCKBX_WRPR                                                                               **
  **           2. EMBP_FCTS_MPWR_VALID_EXT                        **
  **           3. EMBP_FCTS_MPWR_INP			                                                                        **
  **           4. EMBP_FCTS_MPWR_RCPT_KWD		                                                                        **
  ** VERSION HISTORY   :                                                                                                **
  ** VERSION DATE           DEVELOPER                              DESCRIPTION                                          **
  ** ------- -----------    -----------------------                ----------------------------------------             **
  **  1.0    07/10/2017     COGNIZANT OFFSHORE               		INITIAL VERSION                                     **
  ***********************************************************************************************************************/

    PROCEDURE EMBP_FCTS_MPWR_VALID_EXT
    (
        PERRMSG    OUT VARCHAR2,
        PERRCODE   OUT VARCHAR2
    );
/*
    PROCEDURE EMBP_FCTS_MPWR_INP
    (
        PRESULT_MSG    OUT VARCHAR2,
        PERRCODE 	   OUT VARCHAR2
    );

    PROCEDURE EMBP_FCTS_MPWR_RCPT_KWD
    (  
        PRESULT_MSG OUT VARCHAR2,
        PERRCODE OUT VARCHAR2
    );
*/	
END EMBPKG_FCTS_MPWR_INT;
/
CREATE OR REPLACE PACKAGE BODY FACETS_CUSTOM.EMBPKG_FCTS_MPWR_INT
AS
    /* ***********************************************************************************************************
    **                      DECLARE LOCAL VARIABLES                                                            **
    *************************************************************************************************************/
    LV_STATUS_SUCCESS      VARCHAR2(10) :='SUCCESS'; -- SUCCESS STATUS
    
    --------------------------------------------------------------------
    -- VARIABLES FOR SP AUDIT LOGGING.
    --------------------------------------------------------------------
    lvinterfacename        VARCHAR2(50) := 'MONTHLY PREMIUM WITH-HOLD REPORT';  
    LVINTERFACERUNDATE     DATE         := SYSDATE;   
	LV_CURRENTSTEP    	   NUMBER(4,2) := 0;	
    LVCBASECOUNT           NUMBER       := 10000;
    lvprocname             VARCHAR2(30) := 'EMBPKG_FCTS_MPWR_INT';
    LVUSERID               VARCHAR2(20) := USER;
    LVSUCCESSMSG           VARCHAR2(10) := 'SUCCESS';
    LVFAILMSG              VARCHAR2(10) := 'FAILURE';
    LNROWCOUNT             NUMBER(10,2);
    LVLOGINCR              NUMBER(4)    := 1000;
    LVCTRUNCSTATUS         VARCHAR2(400);
    PRESULT_MSG            VARCHAR2(200);
	LNROWAFF               NUMBER        := 0;

	-- 
  PROCEDURE EMBP_FCTS_MPWR_VALID_EXT
   /* ***********************************************************************************************************************
    ** OBJECT NAME       : EMBP_FCTS_MPWR_VALID_EXT                   	   
    ** PREPARED BY       : COGNIZANT OFFSHORE						    	
    ** PURPOSE           : SP WILL VALIDATE THE HEADER, DETAIL AND TRAILER RECORDS IN STAGE TABLES
	**					   AND LOAD THE ERRORED RECORDS INTO ERR_TABLE ALONG WITH ERROR_KEY
    ** DEPENDENCIES      :                        
    **    A. TABLES      : 
    **                                            
    **  INPUT  PARAMETERS :
    **
    **  OUTPUT PARAMETERS :
    **
    ***********************************************************************************************************************/
    (
      PERRMSG OUT VARCHAR2,
      PERRCODE OUT VARCHAR2
    )
  IS
	/* *************************************************
    **           DECLARE LOCAL VARIABLES             **
    ***************************************************/

	lvctruncstatus    VARCHAR2(5000);
    LVTABLENAME       VARCHAR2(128) := 'EMBT_FCTS_MPWR_ERROR';
	LDTSTEPRUNDTM     TIMESTAMP(6)  := SYSTIMESTAMP;
    LDTSTEPENDDTM     TIMESTAMP(6)  := SYSTIMESTAMP;
    LVCERRORMSG       VARCHAR2(300) := NULL;
    LVCUSERNAME       VARCHAR2(20)  := USER;
	PV_SPERRORMSG     VARCHAR2(2000);
    lv_procedurename  VARCHAR2(128) := 'EMBP_FCTS_MPWR_VALID_EXT';
    lvcsuccessstatus  VARCHAR2(10)  := 'SUCCESS';
	LVCSTEPMSG        VARCHAR2(100);
	LV_CURRENTSTEP    NUMBER(4,2) := 0;
	LV_ERRORCODE	   VARCHAR2(128);
	
	/***********************************************************************************************
          To hold the exception list, if any thing raised on Truncate SP.
    ************************************************************************************************/
	
	TYPE LV_REC_TYPE IS RECORD
        (
          LV_TABLE_NAME    VARCHAR2(30),
          LV_ERROR_STATUS  VARCHAR2(32767)
        );

        TYPE LV_TABLE IS TABLE OF LV_REC_TYPE INDEX BY PLS_INTEGER;

        LV_ERRO_HANDLE  LV_TABLE;

        LVRINDEX              BINARY_INTEGER;
        LVSLNO                PLS_INTEGER;
        LVSOFAR               NUMBER  :=  0;
        LVTOTWRK              NUMBER  :=  46;
        LVTAR_DESC            VARCHAR2(4000);
  
  BEGIN

		  DBMS_APPLICATION_INFO.SET_MODULE(lvinterfacename,lvprocname);
		  lvprocname := 'EMBP_CLAIMS_GL_WRAPPER';
		  DBMS_APPLICATION_INFO.SET_ACTION(ACTION_NAME => lv_procedurename);
	  
    	  /* **********************************
		   **   TRUNCATE ALL STAGE TABLES    **
		   ************************************/

          FACETS_STAGE.EMBP_PCKG_INTF_COMMON.EMBP_TRUNCATE_TBL('FACETS_STAGE', 'EMBT_FCTS_MPWR_INP', lvctruncstatus);
          LV_ERRO_HANDLE(LV_ERRO_HANDLE.COUNT + 1).LV_TABLE_NAME  := 'EMBT_FCTS_MPWR_INP';
          LV_ERRO_HANDLE(LV_ERRO_HANDLE.COUNT).LV_ERROR_STATUS    := lvctruncstatus;

          FACETS_STAGE.EMBP_PCKG_INTF_COMMON.EMBP_TRUNCATE_TBL('FACETS_STAGE', 'EMBT_MPWR_RCPT_KWD', lvctruncstatus);
          LV_ERRO_HANDLE(LV_ERRO_HANDLE.COUNT + 1).LV_TABLE_NAME  := 'EMBT_MPWR_RCPT_KWD';
          LV_ERRO_HANDLE(LV_ERRO_HANDLE.COUNT).LV_ERROR_STATUS    := lvctruncstatus;
		  
		  FACETS_STAGE.EMBP_PCKG_INTF_COMMON.EMBP_TRUNCATE_TBL('FACETS_STAGE', 'EMBT_FCTS_MPWR_ERROR', lvctruncstatus);
          LV_ERRO_HANDLE(LV_ERRO_HANDLE.COUNT + 1).LV_TABLE_NAME  := 'EMBT_FCTS_MPWR_ERROR';
          LV_ERRO_HANDLE(LV_ERRO_HANDLE.COUNT).LV_ERROR_STATUS    := lvctruncstatus;
		  
		  PERRMSG := NULL;
		  
		  /***********************************************************************************************
          **          Checking if any errors occured in truncating, if any, it will stop the further    **
          **          execution.																		**
          ************************************************************************************************/

             FOR I IN 1..LV_ERRO_HANDLE.COUNT
             LOOP
                IF LV_ERRO_HANDLE(I).LV_ERROR_STATUS <> 'Successful'
                THEN
                   PERRMSG := PERRMSG||','||LV_ERRO_HANDLE(I).LV_TABLE_NAME||' -- '||LV_ERRO_HANDLE(I).LV_ERROR_STATUS;
                END IF;

             END LOOP;

             IF PERRMSG IS NOT NULL
             THEN
                PERRCODE := '1';
                PERRMSG  := 'Error in trancate '||SUBSTR(PERRMSG,2);
                RAISE_APPLICATION_ERROR(-20020,PERRCODE||' -- '||PERRMSG);
             END IF;

		   /* ********************************************************************************************
			**           Join Header and Detail records on MCO number and get received date             **
			**********************************************************************************************/
    
			LV_CURRENTSTEP := 2.0;
			
INSERT 
	INTO FACETS_STAGE.EMBT_FCTS_MPWR_INP
			(
			MCO_CONTRACT_NUM,
			PMT_RCV_DT		,
			RPT_RCV_DT		,
			PLAN_BNFT_ID	,
			PLAN_SEG_ID		,
			HIC_NUM			,
			SURNAME			,
			FIRST_INITIAL	,
			SEX				,
			DATE_OF_BIRTH	,
			PREM_PMT_OPT	,
			PREM_START_DT	,
			PREM_END_DT		,
			MONTH_NUM		,
			PREM_AMT_C		,
			PREM_AMT_D		,
			PENL_AMT_D		
			)
			SELECT 
				MPWR_HDR.MCO_CONTRACT_NUM,
				PMT_RCV_DT,
				RPT_RCV_DT,
				PLAN_BNFT_ID	,
				PLAN_SEG_ID		,
				HIC_NUM			,
				SURNAME			,
				FIRST_INITIAL	,
				SEX				,
				DATE_OF_BIRTH, 
				PREM_PMT_OPT	,
				PREM_START_DT, 
				PREM_END_DT,
				MONTH_NUM		,
				PREM_AMT_C		,
				PREM_AMT_D 		,
				PENL_AMT_D
	FROM 
				FACETS_STAGE.EMBT_FCTS_MPWR_HEADER_STG MPWR_HDR
			INNER JOIN 
				FACETS_STAGE.EMBT_FCTS_MPWR_DTL_STG	MPWR_DTL
			ON 
				MPWR_DTL.MCO_CONTRACT_NUM = MPWR_HDR.MCO_CONTRACT_NUM;	
			
			/* **************************************************************************
			**           Create recipt keyword data from the Stage input table         **
			*****************************************************************************/
			
			LV_CURRENTSTEP := 3.0;
			
			INSERT ALL
				WHEN (KWD_RCPT_AMT <= 0 ) THEN 
			INTO 
				FACETS_STAGE.EMBT_FCTS_MPWR_ERROR 
			(ERR_GRGR_ID, ERR_SBSB_ID, ERR_RCPT_RCVD_DT, ERR_RCPT_AMT)
			VALUES(KWD_GRGR_ID, KWD_SBSB_ID, KWD_RCPT_RCVD_DT, KWD_RCPT_AMT)
			ELSE
				INTO 
					FACETS_STAGE.EMBT_MPWR_RCPT_KWD
			SELECT 
				GRGR.GRGR_ID AS KWD_GRGR_ID,
				SBSB.SBSB_ID AS KWD_SBSB_ID,
				' ' 
							 AS KWD_RCPT_PAY_METH,
				' '          AS KWD_RCPT_MCTR_RSN,
				PMT_RCV_DT	 AS KWD_RCPT_RCVD_DT ,
				'E'			 AS KWD_RCPT_CD		 ,
				NVL(PREM_AMT_C, 0) + NVL(PREM_AMT_D, 0)
							 AS KWD_RCPT_AMT	 ,
				NULL 		 AS KWD_RCPT_CLASS
			FROM 
				FACETS_STAGE.EMBT_FCTS_MPWR_INP MPWR_INP
			INNER JOIN
				FACETS.CMC_MEME_MEMBER MEME
			ON 
				MEME.MEME_HICN = MPWR_INP.HIC_NUM
			INNER JOIN
				FACETS.CMC_SBSB_SUBSC SBSB
			ON 
				MEME.GRGR_CK = SBSB.GRGR_CK 
			AND
				SBSB.SBSB_CK = MEME.SBSB_CK
			INNER JOIN 
				FACETS.CMC_GRGR_GROUP GRGR
			ON 
				GRGR.GRGR_CK  = SBSB.GRGR_CK
			;
			
		/*Insert Missing HIC Numbers into KWD table*/	
		INSERT INTO FACETS_STAGE.EMBT_MPWR_RCPT_KWD
			SELECT 
				'00000000'   AS KWD_GRGR_ID,
				'000' 		 AS KWD_SBSB_ID,
				' ' 
							 AS KWD_RCPT_PAY_METH,
				' '          AS KWD_RCPT_MCTR_RSN,
				PMT_RCV_DT	 AS KWD_RCPT_RCVD_DT ,
				'E'			 AS KWD_RCPT_CD		 ,
				NVL(PREM_AMT_C, 0) + NVL(PREM_AMT_D, 0)
							 AS KWD_RCPT_AMT	 ,
				NULL 		 AS KWD_RCPT_CLASS
			FROM 
				FACETS_STAGE.EMBT_FCTS_MPWR_INP MPWR_INP
			WHERE 
				MPWR_INP.HIC_NUM NOT IN 
									( SELECT MEME_HICN FROM FACETS.CMC_MEME_MEMBER);
		
		
		COMMIT;
		LV_CURRENTSTEP := 3.0;
	
		EXCEPTION
			WHEN OTHERS THEN
			 ROLLBACK;
			 PERRCODE := '1';
			 PERRMSG  := LVFAILMSG;
			 RAISE_APPLICATION_ERROR(-20021,'Error....!. Details:- '||SQLERRM||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
				  
  
  END EMBP_FCTS_MPWR_VALID_EXT;

END EMBPKG_FCTS_MPWR_INT;
/
GRANT EXECUTE ON FACETS_CUSTOM.EMBPKG_FCTS_MPWR_INT to FACETS_LOAD, DEVELOPER;
