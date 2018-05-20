CREATE OR REPLACE PACKAGE test_pkg    
AS
  PROCEDURE proc_1;
  PROCEDURE proc_2;
  PROCEDURE proc_3;
END;
/
CREATE OR REPLACE PACKAGE BODY test_pkg AS

  PROCEDURE proc_1 AS
  BEGIN
    proc_2;
  END; 

  PROCEDURE proc_2 AS
  BEGIN
    proc_3;
  END;

  PROCEDURE proc_3 AS
  BEGIN
    display_call_stack;
  END;

END;
/
CREATE OR REPLACE PACKAGE BODY test_pkg AS

    PROCEDURE proc_1
        AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Starting Proc1');
        PROC_2;
        PROC_3;
    EXCEPTION
        WHEN OTHERS THEN
          CUSTOM_CALL_STACK.DISPLAY_ERROR_STACK;
    END;

    PROCEDURE proc_2
        AS
    BEGIN
        RAISE DUP_VAL_ON_INDEX;
    
    EXCEPTION
        WHEN OTHERS THEN
          RAISE;
    END;

    PROCEDURE proc_3
        AS
    BEGIN
        RAISE NO_DATA_FOUND;
    EXCEPTION
        WHEN OTHERS THEN
      RAISE;
    END;
END;
/

EXEC test_pkg.proc_1;