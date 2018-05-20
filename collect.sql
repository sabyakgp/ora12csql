
create or replace procedure collect  
is 
cursor t1 is 
	select  
		colA, 
		colB 
	from 
		t1; 
type t1_rec is table of t1%rowtype index by binary_integer; 
 
 type t2_type is RECORD  
 					( 
 						colA t2.colA%TYPE, 
 						colB t2.colB%TYPE, 
 						colC t2.colC%TYPE 
 					); 
 type t2_rec is table of t2_type index by binary_integer; 

 type t2_excp is table of t2_type index by binary_integer;
 
 t1_recs t1_rec; 
 t2_recs t2_rec;
 lvDate timestamp(3); 
 lvStart timestamp(3);
 lvEnd timestamp(3);

 dml_errors EXCEPTION;
 PRAGMA EXCEPTION_INIT(dml_errors, -24381); 

 type cola is table of number index by binary_integer;

 type colb is table of number index by binary_integer;

 type colc is table of timestamp index by binary_integer;

 error_message VARCHAR2(100);

 bad_stmt_no PLS_INTEGER;
 bad_cola t2.cola%type;
 bad_colb t2.colb%type;
 bad_colc t2.colc%type; 
 
begin 
 	open t1; 
 	fetch t1 bulk collect into t1_recs; 
 	close t1; 
-- 	lvDate := SYSTIMESTAMP; 
    lvDate := SYSDATE;
 
	for i in 1..t1_recs.count loop 
		if t1_recs(i).colA in (2,3) then 
			lvDate := lvDate + INTERVAL '1' SECOND;
		end if;	
--		lvDate := lvDate + INTERVAL '1' SECOND;
 		t2_recs(i).colA := t1_recs(i).colA; 
 		t2_recs(i).colB :=  t1_recs(i).colB; 
		t2_recs(i).colC := lvDate;
	end loop;
 
 	forall i in 1..t1_recs.count save exceptions 
 		insert  
 			into t2 
 		values(t2_recs(i).colA, t2_recs(i).colB, t2_recs(i).colC);

 
 exception  
 	
 	when dml_errors then 
 		for i in 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
 			error_message := SQLERRM(-(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
 			DBMS_OUTPUT.PUT_LINE (error_message);
 			bad_stmt_no := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
 			DBMS_OUTPUT.PUT_LINE('Bad statement #: ' || bad_stmt_no);
 			bad_cola := t2_recs(bad_stmt_no).colA;
 			bad_colb := t2_recs(bad_stmt_no).colB;
 			bad_colc := t2_recs(bad_stmt_no).colC;
 			DBMS_OUTPUT.PUT_LINE('Bad ColA #: ' || bad_cola);
 			DBMS_OUTPUT.PUT_LINE('Bad ColB #: ' || bad_colb);
 			DBMS_OUTPUT.PUT_LINE('Bad ColC #: ' || bad_colc);
 		end loop;
 		commit;
 	when others then 
 		dbms_output.put_line ('Job failed'); 
 		raise; 
 end collect; 
/ 
show errors 
