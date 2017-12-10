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
type t2_rec is table of t2_type	idex by binary_integer;

t1_recs t1_rec;
t2_recs t2_rec;
lvDate timestamp(3);

begin
	open t1;
	fetch t1 bulk collect into t1_recs;
	close t1;
	lvDate := SYSTIMESTAMP;

	for i in 1..t1_recs.count loop
		t2_recs.extend;
		t2_recs(i).colA := t1_recs(i).colA;
		t2_recs(i)

	forall i in 1..t1_recs.count save exceptions
		insert 
			into t2
		values(t1_recs(i).colA, t1_recs(i).colB, lvDate);
		lvDate := lvDate + INTERVAL '1' SECOND;

commit;
exception 
	when others then
		dbms_output.put_line ('Job failed');
		raise;
end collect;
/
show errors
