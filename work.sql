drop table t1;
/
create table t1 (
trans_code varchar2(2),
disp_cd varchar2(1),
prdct_comp_id varchar2(4),
mod1 integer
);
/
insert into t1
values ('01', 'M', 'M001', 1);
insert into t1
values ('35', 'M', 'B001', 1);
insert into t1
values ('07', 'R', 'M001', 1);
insert into t1
values ('07', 'R', 'B001', 1);
insert into t1
values ('08', 'R', 'M001', -1);
insert into t1
values ('08', 'R', 'B001', -1);
/
SELECT 
/
CREATE OR REPLACE FUNCTION EMBF_GET_TRANS_CD (BILL_DISP_CD IN VARCHAR2, BL_COMP_ID IN VARCHAR2, MOD_1 INTEGER)
RETURN VARCHAR2 
AS
TRANS_CODE VARCHAR2(2);
BEGIN
  SELECT 
    TRANS_CODE
  INTO TRANS_CODE
  FROM T1
  WHERE DISP_CD = BILL_DISP_CD AND PRDCT_COMP_ID = BL_COMP_ID AND MOD1 = MOD_1;
RETURN TRANS_CODE;
END;
/
drop table mbr_stage
/
create table mbr_stage
(
blei_ck integer,
prdct_comp_id varchar2(4),
bill_disp_cd varchar2(2),
bill_prm number(18,4)
);
/
insert into mbr_stage
values(100, 'M001', 'M', 200);
insert into mbr_stage
values(100, 'B001', 'M', 200);
insert into mbr_stage
values(100, 'M001', 'R', 200);
insert into mbr_stage
values(100, 'B001', 'R', 200);
insert into mbr_stage
values(100, 'M001', 'R', -50);
insert into mbr_stage
values(100, 'B001', 'R', -20);
/
commit
/
select 
embf_get_trans_cd(bill_disp_cd, prdct_comp_id, bill_prm/(abs(bill_prm)*1)) as trans_code,
/*1
  case 
    when bill_disp_cd = 'R' and bill_prm > 0 then 
      embf_get_trans_cd(bill_disp_cd, prdct_comp_id, 1)
    when bill_disp_cd = 'R' and bill_prm < 0 then 
      embf_get_trans_cd(bill_disp_cd, prdct_comp_id, -1)
    else 
      embf_get_trans_cd(bill_disp_cd, prdct_comp_id, 1)
    end as trans_code,
*/    
    blei_ck,
    bill_disp_cd,
    prdct_comp_id,
    bill_prm
from 
  mbr_stage;
/
select * from mbr_stage;
/
commit
/
select -200/(abs(-200)*1) from dual;
/
select  * from 
(select level from dual connect by level < 3) trn,
mbr_stage

--on trn.trn_type = blei_ck