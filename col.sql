declare
TYPE My_Rec IS RECORD (a NUMBER, b NUMBER);
Rec My_Rec;
TYPE RecTbl IS TABLE OF My_Rec;
Recd RecTbl := RecTbl();
i NUMBER := 1;
begin
loop 
exit when i > 100;
	Rec.a := i;
	Rec.b := i;
	Recd.extend;
	Recd(i) := Rec;
	i := i+1;
end loop;
for i in Recd.FIRST .. Recd.LAST 
loop
dbms_output.put_line(Recd(i).a);
dbms_output.put_line(Recd(i).b);
end loop;
end;
/
