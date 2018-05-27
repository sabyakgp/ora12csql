set serveroutput on
Rem Testing optimistic locking
-- var dno number
-- var dname varchar2(14)
-- var loc varchar2(13)
-- var last_mod varchar2(50)
-- begin
-- 	:dno := 10;
-- 	select 
-- 		dname, loc, to_char(last_mod, 'DD-MON-YYYY HH.MI.SSXFF AM TZR')
-- 	into
-- 		:dname, :loc, :last_mod
-- 	from hr.dept
-- 	where deptno = :dno;
-- end;
-- /
-- select :dno department, :dname name, :loc location, :last_mod last_mod
-- from dual;
-- /
var cnt number
begin	
	:loc := 'Paris';
	:cnt := 0;
update
	hr.dept 
set 
	loc = :loc,
	last_mod = systimestamp
where deptno = :dno and last_mod = to_timestamp_tz(:last_mod, 'DD-MON-YYYY HH.MI.SSXFF AM TZR');
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
