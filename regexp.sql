--display employees whose first name is Stephen or Steven
--select * from hr.employees where regexp_like(first_name, '^Ste(V|ph)en$');
--display number of times character a or e occurs in the literal
--select regexp_count('Albert Einstein', 'a|e', 1, 'i') from dual;
--select regexp_instr('Sabyasachisabyasachikgp@gmail.com','\w+@\w+(\.\w+)+') 
--from dual;
--display first and last name
--select regexp_substr('sabyasachi mitra','\w+\s',1) as first_name,
--regexp_substr('sabyasachi mitra','\s\w+') as last_name
--from dual;
--select regexp_substr('sabyasachi mitra','\s+\w+') as last_name from dual;
--back reference - replace name with salutaion + name
--select regexp_replace(first_name,'(.+)','Mr. \1')
--from hr.employees;
/
select 1 from dual where regexp_like ('ABC UNITE XYZ', 'Unite', 'c')
/
select regexp_instr('ABC UNITE XYZ', '\\UNITE', 1,1,0, 'c') from dual