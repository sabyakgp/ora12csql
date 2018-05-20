declare
	test varchar2(10);
begin
	test := '885      ';
	dbms_output.put_line(length(trim(test)));
end;
/
