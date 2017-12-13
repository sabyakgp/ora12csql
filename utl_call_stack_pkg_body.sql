CREATE OR REPLACE PACKAGE BODY utl_call_stack_pkg
AS
	PROCEDURE proc1 AS
	BEGIN
		proc2;
	END;

	PROCEDURE proc2 AS
	BEGIN
		proc3;
	END;

	PROCEDURE proc4 AS
	BEGIN
		DBMS_OUTPUT.put_line('Nothing');
	END;

	PROCEDURE proc3 AS
	BEGIN
		RAISE NO_DATA_FOUND;
		proc4;

	EXCEPTION 
		WHEN OTHERS THEN
			display_error_stack;
			raise;
	END proc3;
END utl_call_stack_pkg;
/
