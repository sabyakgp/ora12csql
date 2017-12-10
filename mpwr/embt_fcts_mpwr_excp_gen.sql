/**********************************************************************************************************************************
** Table Name      EMBT_FCTS_MPWR_EXCP_NGTV                                                                                      **
** Purpose        : Please enter the purpose of table                                                                            **
** Version Number : 1.0                                                                                                          **
** Version   Date           Developer                   Description                                                              **
** --------  -----------    --------------------        ------------------------                                                 **
** 1.0       07/31/2017     Sabyasachi Mitra            Initial Version  														 **
**********************************************************************************************************************************/

/***************************************************************************
**   DROP TABLE IF AVAILABLE                                             **
***************************************************************************/
DECLARE
	sqlString VARCHAR2(100);
	v_Cursor BINARY_INTEGER;
	v_ReturnCode BINARY_INTEGER;
	p_Table VARCHAR2(100) NOT NULL := 'EMBT_FCTS_MPWR_EXCP_GEN';
BEGIN
	sqlString := 'DROP TABLE ' || p_Table;
	v_Cursor := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(v_Cursor, sqlString, DBMS_SQL.NATIVE);
	v_ReturnCode := DBMS_SQL.EXECUTE(v_Cursor);
	dbms_output.put_line(v_ReturnCode);
	DBMS_SQL.CLOSE_CURSOR(v_Cursor);
END;
/
/***************************************************************************
**   CREATING TABLE                                                       **
***************************************************************************/
CREATE TABLE EMBT_FCTS_MPWR_EXCP_GEN
(
HICN_NBR VARCHAR2(12),
PYMT_DUE_DT DATE,
PART_C_PREM NUMBER(18,4),
PART_D_PREM NUMBER(18,4),
PART_D_LEP  NUMBER(18,4),
TOTL_PREM   NUMBER(18,4),
REASON_DESC VARCHAR2(255)
);
