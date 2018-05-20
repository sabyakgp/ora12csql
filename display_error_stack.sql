CREATE OR REPLACE PROCEDURE display_error_stack
as
lv_depth PLS_INTEGER;
lv_error_depth PLS_INTEGER;
lv_bck_trace PLS_INTEGER;
lv_Error_Pgm VARCHAR2(60);
lv_temp PLS_INTEGER;
BEGIN
	lv_error_depth := UTL_CALL_STACK.error_depth;
	lv_depth := UTL_CALL_STACK.dynamic_depth;

	DBMS_OUTPUT.put_line('***** Error Stack Start *****');
	DBMS_OUTPUT.put_line('Depth     Error     Error                                        ');
	DBMS_OUTPUT.put_line('.         Number    Message                                      ');
	DBMS_OUTPUT.put_line('--------- --------- ---------------------------------------------');

	FOR i in 1 .. lv_error_depth LOOP 	
		DBMS_OUTPUT.put_line
		(
      		RPAD(i, 10) ||
      		RPAD('ORA-' || LPAD(UTL_CALL_STACK.error_number(i), 5, '0'), 10) ||
      		UTL_CALL_STACK.error_msg(i)    			
      	);
	END LOOP;


	DBMS_OUTPUT.put_line('***** Error Stack End *****');

	DBMS_OUTPUT.put_line('---------------------------------------------------------------------------------');

	DBMS_OUTPUT.put_line('***** Call Stack Start *****');
	DBMS_OUTPUT.put_line('Depth     Lexical   Line      Owner     Edition   Name');
  	DBMS_OUTPUT.put_line('.         Depth     Number');
  	DBMS_OUTPUT.put_line('--------- --------- --------- --------- --------- --------------------');

	FOR i in 1 .. lv_depth LOOP
		
		lv_temp := i + 1;
      
        IF lv_temp = lv_depth THEN 
      	   lv_Error_Pgm := UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(i));
      	   --REGEXP_SUBSTR(UTL_CALL_STACK.concatenate_subprogram(UTL_CALL_STACK.subprogram(i)), '(^|\.)([^\.]*)',1,4,'i',2);
        END IF;

--        DBMS_OUTPUT.PUT_LINE('Pgm Name ' || lv_Error_Pgm);
		
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

	lv_bck_trace := UTL_CALL_STACK.backtrace_depth;

	DBMS_OUTPUT.put_line('***** Backtrace Start *****');

    DBMS_OUTPUT.put_line('Depth     Error     BTrace');
    DBMS_OUTPUT.put_line('.         Line       Unit');
    DBMS_OUTPUT.put_line('--------- --------- --------------------');

    FOR i IN 1 .. lv_bck_trace LOOP
     DBMS_OUTPUT.put_line(
       RPAD(i, 10) ||
       RPAD(TO_CHAR(UTL_CALL_STACK.backtrace_line(i),'99'), 10) ||
       lv_Error_Pgm
     );
    END LOOP; 

  DBMS_OUTPUT.put_line('***** Backtrace End *****');


END;
/
show error