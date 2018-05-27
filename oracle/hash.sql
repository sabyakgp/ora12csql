var deptno number
var dname varchar2(14)
var loc varchar2(13)
-- var hash varchar2(32767)
var cnt number
declare
	hashr raw(32767);
begin
	-- select 
	-- 	deptno, dname, loc, utl_raw.cast_to_varchar2(standard_hash(dname||loc, 'SHA512'))
	-- into :deptno, :dname, :loc, :hash
	-- from hr.dept
	-- where deptno = 10;
-- dbms_output.put_line(:dname || ' ' || :loc || ' ' || :hash);
	select 
		utl_raw.cast_to_raw(:hash)
	into
		hashr 
	from dual;
	dbms_output.put_line(hashr);
	update hr.dept
		set dname = lower(:dname)
	where
		deptno = :deptno and
		utl_raw.cast_to_varchar2(standard_hash(dname||loc, 'SHA512')) = :hash;
	:cnt := sql%rowcount;
	if :cnt = 0 then 
		raise_application_error(-20010, 'Zero rows updated');
	end if;
	commit;
exception 
	when others then
	dbms_output.put_line('zero rows updated: plsql block failed');
end;
/
-- select 
-- 	:deptno, :dname, :loc, :hash 
-- from dual;
