create table stage.input
(
mco varchar2(5),
rcpt_rcvd_dt date,
rcpt_amt number(18,4),
hicn varchar2(6)
);
grant select, insert, update, delete on stage.input to custom;
