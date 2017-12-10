CREATE OR REPLACE PACKAGE   EMBPKG_COMMON_HANDLER IS
      
      TYPE EMBREC_MODULE_DTL IS RECORD (
                                         MODULE_NAME  VARCHAR2(48) DEFAULT NULL,
                                         ACTION_NAME  VARCHAR2(32) DEFAULT NULL,
                                         CLIENT_INFO  VARCHAR2(64) DEFAULT NULL --Length is 64 byte
                                       );
                                       
      GV_MODULE_DTL EMBREC_MODULE_DTL;  /* Have to assign values to this record at first step of code.
                                          ex:- GV_MODULE_DTL.MODULE_NAME := 'Set the module name, can give the interface name.',
                                               GV_MODULE_DTL.ACTION_NAME := 'Set the action name, can your package(or)procedure name.'
                                               GV_MODULE_DTL.CLIENT_INFO := 'Additional information about our application.'
                                          We can find out the long running queries using this 3 values, in v$session_longops,v$session, v$sql, and v$sqltext.
                                        */
      
      GV_ACTION_NAME  VARCHAR2(32);     /* Set the action name of every procedure in your Package at first step of the procedure. 
                                           We can use procedure name as action name.
                                        */
      LV_RINDEX      BINARY_INTEGER  := DBMS_APPLICATION_INFO.SET_SESSION_LONGOPS_NOHINT;
      LV_SLNO        BINARY_INTEGER;
      GV_SOFAR       NUMBER := 0; -- The amount work which has been done Sofar. Have to initialize this variable as 0 in starting of your interface. ex:- EMBPKG_EXCE_HANDLING.GV_SOFAR := 0;
      GV_TOT_WORK    NUMBER := 0; -- Total number of work to be done in this module. Have to initialize this variable as total number transaction(eg., DML, DDL, Calling procedure, etc.,) in starting of your interface. 
                                  -- eg:- EMBPKG_EXCE_HANDLING.GV_SOFAR := 10, 10 means current interface having 10 transactions.
      LV_TARG_DESC  VARCHAR2(2000);
      
      GV_START_TIME PLS_INTEGER;
      
      /* Call EMBP_EXCEPTION procedure in exception block, insted of using DBMS_OUTPUT.PUT_LINE(), RAISE_APPLICATION_ERROR().
         This procedure will take care printing the exception and raising the exceptions. Please refer the below example.
         
         PROCEDURE PRC_TEST
         IS
            VAR1  VARCHAR2(1);
         BEGIN
            VAR1 := 'TEST';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_EXCEPTION('-20001','Data not available....!');  --> This one for error code and error message.
            WHEN OTHERS THEN
                FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_EXCEPTION(SQLERRM);  --> This one for Pre defined Oracle Error Message.                
         END;
      */
      PROCEDURE EMBP_EXCEPTION(                                     
                               PERR_MSG           VARCHAR2 DEFAULT NULL,  -- Oracle Error Message, Need to pass SQLERRM
                               PCUSTOM_ERR_CODE   VARCHAR2 DEFAULT NULL,  -- User Defined Error Code.
                               PCUSTOM_ERR_MSSAGE VARCHAR2 DEFAULT NULL   -- User Defined Error Message.
                              );
                              
      /* 
        EMBP_SESSION_STEP_LOG procedure call before the every transactions. 
        Please refer the following example.
        PROCEDURE PRC_TEST
        IS
            VAR1  VARCHAR2(1);
         BEGIN
              
              -- Following 4 statment, should be first 4 statments of your main procedure of the package.
              
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.GV_MODULE_DTL.MODULE_NAME := 'TESTING PROCESS'; --Pass your interface name
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.GV_MODULE_DTL.ACTION_NAME := 'PRC_TEST'; -- Pass the Package (or) Procedure Name.
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.GV_MODULE_DTL.CLIENT_INFO := 'Checking for Testing purpose'; -- Pass aditional information about this interface, if its required, else not required. Length is 64 byte
              
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.GV_TOT_WORK := 2; Two DML operations are doing, so i ahve assigned to 2.
              
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.GV_ACTION_NAME := 'PRC_TEST'; -- If your package having more than one procedure this statment should be first statment and assign the current procedure name.
              
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_SESSION_STEP_LOG(
                                                                        P_TARGET      => 1,
                                                                        P_TARGET_DESC => 'Inserting in Table 1' -- It will accept only 32 byte length, so put short and meaning description.
                                                                       ); 
              INSERT INTO 
                  TABLE_1
              SELECT 
                  * 
              FROM
                  TABLE_1;
              
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_LOGGER(
                                                             P_ROWCOUNT    => SQL%ROWCOUNT,
                                                             P_TARGET_DESC => 'Inserting in Table 1'
                                                            )  ;
                                                            
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_SESSION_STEP_LOG(
                                                                        P_TARGET      => 1,
                                                                        P_TARGET_DESC => 'Updating Table 1' -- It will accept only 32 byte length, so put short and meaning description.
                                                                       ); 
              UPDATE 
                  TABLE_1
              SET
                  COL_1 = 'TEST';
              
              FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_LOGGER(
                                                             P_ROWCOUNT    => SQL%ROWCOUNT,
                                                             P_TARGET_DESC => 'Updating Table 1'
                                                            )  ;                                
            
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_EXCEPTION('-20001','Data not available....!');  --> This one for error code and error message.
            WHEN OTHERS THEN
                FACETS_CUSTOM.EMBPKG_EXCE_HANDLING.EMBP_EXCEPTION(SQLERRM);  --> This one for Pre defined Oracle Error Message.                
         END;
      */                        
      PROCEDURE EMBP_SESSION_STEP_LOG(
                                      P_TARGET      IN     BINARY_INTEGER DEFAULT 0,    -- The object on which the operation is carried out.
                                      P_TARGET_DESC IN     VARCHAR2       DEFAULT 'NO', -- This description, operation which is going to happen. It will accept only 32 byte length.
                                      P_CONTEXT     IN     BINARY_INTEGER DEFAULT 0,    -- Any Number the clients want to store( Not Mandatory).                                                                            
                                      P_UNITS       IN     VARCHAR2       DEFAULT NULL  -- Used for SOFAR and Total Work(Not Mandatory).                                      
                                     );   
      
      /* EMBP_LOGGER procedure call after the every transactions. This will print Affected rows, time taken to process the transaction. */      
      PROCEDURE EMBP_LOGGER(
                            P_ROWCOUNT    IN  PLS_INTEGER,  -- Row count of last executed Transaction. ex:- SQL%ROWCOUNT.
                            P_TARGET_DESC IN  VARCHAR2      -- Pass the same values ,passed in EMBP_SESSION_STEP_LOG P_TARGET_DESC parameter value.
                           );
END EMBPKG_COMMON_HANDLER;
/
create or replace PACKAGE BODY                                           EMBPKG_COMMON_HANDLER IS
        
    PROCEDURE EMBP_EXCEPTION(                                     
                             PERR_MSG           VARCHAR2 DEFAULT NULL,  -- Oracle Error Message, Need to pass SQLERRM
                             PCUSTOM_ERR_CODE   VARCHAR2 DEFAULT NULL,  -- User Defined Error Code.
                             PCUSTOM_ERR_MSSAGE VARCHAR2 DEFAULT NULL   -- User Defined Error Message.
                            )
    IS
       LV_ERRO_MSG_FRMT VARCHAR2(32767);
    BEGIN   
            
        SELECT 'Exception occured in '||
                REGEXP_SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,'(")[A-Z|.|_]+',1,1,'i') 
                ||'" at '||
                REGEXP_SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,'(line)([ |0-9]+)',1,1,'i') 
                ||'. Error Message :- '||
                REGEXP_SUBSTR(PERR_MSG,'(ORA-)([A-Z|0-9|:| ]+)',1,1,'i')
                ||'.'
        INTO
            LV_ERRO_MSG_FRMT
        FROM DUAL;
            
        LV_ERRO_MSG_FRMT := NVL(PCUSTOM_ERR_MSSAGE,LV_ERRO_MSG_FRMT);
            
        RAISE_APPLICATION_ERROR(NVL(PCUSTOM_ERR_CODE,-20001),LV_ERRO_MSG_FRMT);
        
    END EMBP_EXCEPTION;
  
    PROCEDURE EMBP_SESSION_STEP_LOG(
                                    P_TARGET      IN     BINARY_INTEGER DEFAULT 0,    -- The object on which the operation is carried out.
                                    P_TARGET_DESC IN     VARCHAR2       DEFAULT 'NO', -- This description, operation which is going to happen.
                                    P_CONTEXT     IN     BINARY_INTEGER DEFAULT 0,    -- Any Number the clients want to store( Not Mandatory).                                                                            
                                    P_UNITS       IN     VARCHAR2       DEFAULT NULL  -- Used for SOFAR and Total Work(Not Mandatory).
                                   )
    IS
    BEGIN 
          GV_START_TIME := DBMS_UTILITY.GET_TIME;
          DBMS_APPLICATION_INFO.SET_SESSION_LONGOPS(RINDEX       => LV_RINDEX,
                                                    SLNO         => LV_SLNO,
                                                    OP_NAME      => GV_MODULE_DTL.MODULE_NAME,
                                                    SOFAR        => (GV_SOFAR + 1),
                                                    TOTALWORK    => GV_TOT_WORK,
                                                    TARGET       => P_TARGET,
                                                    TARGET_DESC  => P_TARGET_DESC
                                                   );
    END EMBP_SESSION_STEP_LOG;

    /* EMBP_LOGGER procedure call after the every transactions. This will print Affected rows, time taken to process the transaction. */      
    PROCEDURE EMBP_LOGGER(
                          P_ROWCOUNT    IN  PLS_INTEGER,  -- Row count of last executed Transaction. ex:- SQL%ROWCOUNT.
                          P_TARGET_DESC IN  VARCHAR2      -- Pass the same values ,passed in EMBP_SESSION_STEP_LOG P_TARGET_DESC parameter value.
                         )
    IS
    BEGIN
          DBMS_OUTPUT.PUT_LINE('Running Module is - '||GV_MODULE_DTL.MODULE_NAME||
                               '. Current completed Steps - '||P_TARGET_DESC||
                               ', Time taken to complete this transaction is - '||(DBMS_UTILITY.GET_TIME - GV_START_TIME)||
                               '. No of affected rows:- '||P_ROWCOUNT);
          
    END;
END EMBPKG_COMMON_HANDLER;
/
show error