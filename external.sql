drop table stage.payment_ext;
--
create table stage.payment_ext
(
mco varchar2(5),
--rcpt_rcvd_dt date,
rcpt_rcvd_dt varchar2(8),
rcpt_amt number(18,4),
hicn varchar2(8)
)
organization external
(
type oracle_loader
default directory DEV_EXTERNAL
access parameters
(
records delimited by newline 
fields
	(
		mco char(5),
		rcpt_rcvd_dt char(8),
		rcpt_amt char(6),
		hicn char(8)
	)
)
location('mpwr')
)
reject limit unlimited
;
