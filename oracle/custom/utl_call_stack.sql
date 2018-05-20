CREATE OR REPLACE PACKAGE CUSTOM_CALL_STACK
AS
PROCEDURE DISPLAY_CALL_STACK;

PROCEDURE DISPLAY_ERROR_STACK;

PROCEDURE DISPLAY_BACKTRACE;

END CUSTOM_CALL_STACK;
/
CREATE OR REPLACE PACKAGE BODY CUSTOM_CALL_STACK
AS

l_depth PLS_INTEGER;

PROCEDURE DISPLAY_BACKTRACE AS
BEGIN
	
	l_depth := UTL_CALL_STACK.backtrace_depth;

	DBMS_OUTPUT.put_line('***** Backtrace Start *****');

  	DBMS_OUTPUT.put_line('Depth     BTrace     BTrace');
  	DBMS_OUTPUT.put_line('.         Line       Unit');
  	DBMS_OUTPUT.put_line('--------- --------- --------------------');

  	FOR i IN 1 .. l_depth LOOP
	    DBMS_OUTPUT.put_line(
	      RPAD(i, 10) ||
	      RPAD(TO_CHAR(UTL_CALL_STACK.backtrace_line(i),'99'), 10) ||
	      UTL_CALL_STACK.backtrace_unit(i)
	    );
  	END LOOP;

  	DBMS_OUTPUT.put_line('***** Backtrace End *****');
END DISPLAY_BACKTRACE;

PROCEDURE DISPLAY_CALL_STACK AS
BEGIN
	
	l_depth := UTL_CALL_STACK.dynamic_depth;
	DBMS_OUTPUT.put_line('***** Call Stack Start *****');
	DBMS_OUTPUT.put_line('Depth     Lexical   Line      Owner     Edition   Name');
  	DBMS_OUTPUT.put_line('.         Depth     Number');
  	DBMS_OUTPUT.put_line('--------- --------- --------- --------- --------- --------------------');

  	FOR i IN 1 .. l_depth LOOP
	    DBMS_OUTPUT.put_line(
	      RPAD(i, 10) ||
	      RPAD(UTL_CALL_STACK.lexical_depth(i), 10) ||
	      RPAD(TO_CHAR(UTL_CALL_STACK.unit_line(i),'99'), 10) ||
	      RPAD(NVL(UTL_CALL_STACK.owner(i),' '), 10) ||
	      RPAD(NVL(UTL_CALL_STACK.current_edition(i),' '), 10) ||
	      UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(i))
	    );
  END LOOP;
  DBMS_OUTPUT.put_line('***** Call Stack End *****');
 END DISPLAY_CALL_STACK;

 PROCEDURE DISPLAY_ERROR_STACK AS
 BEGIN

 	l_depth := UTL_CALL_STACK.error_depth;

	DBMS_OUTPUT.put_line('***** Error Stack Start *****');

	DBMS_OUTPUT.put_line('Depth     Error     Error');
	DBMS_OUTPUT.put_line('.         Code      Message');
	DBMS_OUTPUT.put_line('--------- --------- --------------------');

  	FOR i IN 1 .. l_depth LOOP
    	DBMS_OUTPUT.put_line(
      	RPAD(i, 10) ||
      	RPAD('ORA-' || LPAD(UTL_CALL_STACK.error_number(i), 5, '0'), 10) ||
      	UTL_CALL_STACK.error_msg(i)
    	);
  	END LOOP; 

  DBMS_OUTPUT.put_line('***** Error Stack End *****');
END DISPLAY_ERROR_STACK;

END CUSTOM_CALL_STACK;
 /
