CREATE OR REPLACE PROCEDURE                              EXCEPTION_TEST_PROD(P_EMP_ID     EMPLOYEES.P_ID%TYPE,
                                                                 P_FIRST_NAME EMPLOYEES.P_NAME%TYPE,
                                                                 P_FLAG        VARCHAR2
                                                                ) IS

LV_NAME EMPLOYEES.P_NAME%TYPE;

BEGIN
    EMBPKG_COMMON_HANDLER.GV_MODULE_DTL.MODULE_NAME := 'TESTING PROCESS';
    EMBPKG_COMMON_HANDLER.GV_MODULE_DTL.ACTION_NAME := 'EXCEPTION_TEST_PRODURE';
    EMBPKG_COMMON_HANDLER.GV_MODULE_DTL.CLIENT_INFO := 'Checking for Testing purpose';
    EMBPKG_COMMON_HANDLER.GV_TOT_WORK := 2;
    
    EMBPKG_COMMON_HANDLER.GV_ACTION_NAME := 'EXCEPTION_TEST_PRODURE'; 
    
    IF P_FLAG ='I'
    THEN
        EMBPKG_COMMON_HANDLER.EMBP_SESSION_STEP_LOG(
                                                                 P_TARGET      => 1,
                                                                 P_TARGET_DESC => 'Inserting in EMP'
                                                                );
                                                                
        INSERT INTO
            EMPLOYEES
        VALUES
            (
             P_EMP_ID,
             P_FIRST_NAME
            );
            
        EMBPKG_COMMON_HANDLER.EMBP_LOGGER(
                                                       P_ROWCOUNT      => SQL%ROWCOUNT,
                                                       P_TARGET_DESC => 'Inserting in EMP'
                                                      ); 
       
       EMBPKG_COMMON_HANDLER.EMBP_SESSION_STEP_LOG(
                                                                 P_TARGET      => 1,
                                                                 P_TARGET_DESC => 'Inserting in EMP2'
                                                                );
                                                                
        INSERT INTO
            EMPLOYEES
        VALUES
            (
             P_EMP_ID,
             P_FIRST_NAME
            );
            
        EMBPKG_COMMON_HANDLER.EMBP_LOGGER(
                                                       P_ROWCOUNT      => SQL%ROWCOUNT,
                                                       P_TARGET_DESC => 'Inserting in EMP2'
                                                      ); 
                                                      
    ELSE
        
        EMBPKG_COMMON_HANDLER.EMBP_SESSION_STEP_LOG(
                                                                 P_TARGET      => 1,
                                                                 P_TARGET_DESC => 'Updating in EMP'
                                                                );
                                                                
        UPDATE
            EMPLOYEES
        SET
            P_NAME = P_NAME 
        WHERE 
            P_ID = P_ID;
        
        EMBPKG_COMMON_HANDLER.EMBP_LOGGER(
                                                       P_ROWCOUNT      => SQL%ROWCOUNT,
                                                       P_TARGET_DESC => 'Updating in EMP'
                                                      ); 
                                                                 
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
    
     EMBPKG_COMMON_HANDLER.EMBP_EXCEPTION(                                     
                                           PERR_MSG           => SQLERRM,  -- Oracle Error Code, Need to pass SQLERRM
                                           PCUSTOM_ERR_CODE   => NULL,     -- User Defined Error Code.
                                           PCUSTOM_ERR_MSSAGE => NULL      -- User Defined Error Message.
                                         );
END EXCEPTION_TEST_PROD;
/
show error