prompt Extract data from external table

DECLARE
lvctruncstatus VARCHAR2(30) := 'SUCCESS';
BEGIN
FACETS_STAGE.EMBP_PCKG_INTF_COMMON.EMBP_TRUNCATE_TBL('FACETS_STAGE', 'EMBT_FCTS_MPWR_INP', lvctruncstatus);

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
commit;	
END;
/
EXIT;