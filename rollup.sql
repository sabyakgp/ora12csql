create table member_pcp
(
member_id varchar2(10),
pcp_id varchar2(10),
pay_dt date
);
insert into member_pcp
values('K010101','PR101010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
insert into member_pcp
values('K010102','PR101010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
insert into member_pcp
values('K010103','PR101010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
insert into member_pcp
values('K010104','PR101010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
insert into member_pcp
values('K020101','PR201010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
insert into member_pcp
values('K020102','PR201010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
insert into member_pcp
values('K020103','PR201010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
insert into member_pcp
values('K020104','PR201010', TO_DATE('12-JAN-2017', 'DD-MON-YYYY'));
---
select mp.member_id, 
	   case 
		grouping_id(mp.member_id, mp.pcp_id) 
	   when 2 then 'Member count of PCP ' || mp.pcp_id
	   when 3 then 'Member count of All PCPs'
	   else mp.pcp_id
	   end as pcp_id,
	count(mp.member_id) as mem_cnt
from
	member_pcp mp
group by rollup(pcp_id, member_id);
	