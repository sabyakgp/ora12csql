create or replace procedure custom.load
is
begin
insert into stage.input
select 
mco,
rcpt_rcvd_dt,
rcpt_amt,
substr(hicn,1,6)
from stage.payment_ext
;
commit;
exception
when others then
rollback;
raise_application_error(-20001,'An Error has occured'||SQLCODE||SQLERRM);
end;
/
