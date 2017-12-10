create table 
payment_stage
(
contract varchar2(5),
pmt_due_dt date,
first_prem number(18,4),
second_prem number(18,4),
fee number(18,4),
total_prem number(18,4),
reason varchar2(50),
run_date date,
run_time timestamp(3)
);
Insert into payment_stage (contract,pmt_due_dt,first_prem,second_prem,fee,total_prem,reason,RUN_DATE,RUN_TIME) values ('H3330',to_date('02-AUG-17','DD-MON-RR'),110,110,-20,280,'NEGATIVE LEP AMOUNT',to_date('02-AUG-17','DD-MON-RR'),to_timestamp('02-AUG-17 05.40.57.744454000 AM','DD-MON-RR HH.MI.SSXFF AM'));
Insert into payment_stage (contract,pmt_due_dt,first_prem , second_prem, fee, total_prem, reason, RUN_DATE,RUN_TIME) values ('H3330',to_date('02-AUG-17','DD-MON-RR'),100,100,-20,180,'NEGATIVE LEP AMOUNT',to_date('02-AUG-17','DD-MON-RR'),to_timestamp('02-AUG-17 05.41.13.409960000 AM','DD-MON-RR HH.MI.SSXFF AM'));
commit;
