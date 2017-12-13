create or replace procedure facets_custom.collect  
is 
cursor t1 is 
	select  
		colA, 
		colB 
	from 
		facets_stage.t1; 
type t1_rec is table of t1%rowtype index by binary_integer; 
 
 type t2_type is RECORD  
 					( 
 						colA facets_stage.t2.colA%TYPE, 
 						colB facets_stage.t2.colB%TYPE, 
 						colC facets_stage.t2.colC%TYPE 
 					); 
 type t2_rec is table of t2_type index by binary_integer; 
 
 t1_recs t1_rec; 
 t2_recs t2_rec;
 lvDate timestamp(3); 
 lvStart timestamp(3);
 lvEnd timestamp(3);
 
 
begin 
 	open t1; 
 	fetch t1 bulk collect into t1_recs; 
 	close t1; 
 	lvDate := SYSTIMESTAMP; 
 
	for i in 1..t1_recs.count loop 
		lvDate := lvDate + INTERVAL '1' SECOND;
 		t2_recs(i).colA := t1_recs(i).colA; 
 		t2_recs(i).colB :=  t1_recs(i).colB; 
		t2_recs(i).colC := lvDate;
	end loop;
 
 	forall i in 1..t1_recs.count save exceptions 
 		insert  
 			into facets_stage.t2 
 		values(t2_recs(i).colA, t2_recs(i).colB, t2_recs(i).colC); 		 
 
 
commit; 
 exception  
 	when others then 
 		dbms_output.put_line ('Job failed'); 
 		raise; 
 end collect; 
/ 
show errors 
