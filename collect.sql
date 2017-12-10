create or replace procedure collect 
is
cursor t1 is
	select 
		colA,
		colB
	from
		t1;
type t1_rec is table of t1%rowtype index by binary_integer;

recs t1_rec;
lvDate timestamp(3);

begin
	open t1;
	fetch t1 bulk collect into recs;
	close t1;
	lvDate := SYSTIMESTAMP;

	forall i in 1..recs.count save exceptions
		insert 
			into t2
		values(recs(i).colA, recs(i).colB, lvDate);
		lvDate := lvDate + INTERVAL '1' SECOND;

commit;
exception 
	when others then
		dbms_output.put_line ('Job failed');
		raise;
end collect;
/
show errors
