/* *********************************************************************************************************************** 
  ** Object Name       : EMBS_FCTS_MPWR_VALID_EXESP                                                                     **
  ** Prepared by       : Cognizant offshore                                                                             **
  ** Prepared Date     : 07/12/2017                                                                                     **
  ** Purpose           : This script will invoke the PL/SQL stored procedure.         									**
  ** Dependencies      :																								**
  ** Version History   :                                                                                                **
  ** Version Date           Developer                  			Description                                     		**
  ** ------- -----------    -----------------------    			----------------------------------------        		**
  **  1.0    07/11/2017     Cognizant Offshore               Initial Version                                       		**
  ***********************************************************************************************************************/
WHENEVER SQLERROR EXIT FAILURE
WHENEVER OSERROR EXIT FAILURE
SET SERVEROUTPUT ON;


DECLARE
		PERRMSG    VARCHAR2(200);
        PERRCODE   VARCHAR2(200);
BEGIN
FACETS_CUSTOM.EMBPKG_FCTS_MPWR_INT.EMBP_FCTS_MPWR_VALID_EXT
(
		PERRMSG => PERRMSG,
		PERRCODE => PERRCODE
);
DBMS_OUTPUT.PUT_LINE('PERRMSG = ' || PERRMSG);
DBMS_OUTPUT.PUT_LINE('PERRCODE = ' || PERRCODE);
END;
/
EXIT;