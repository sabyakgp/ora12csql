--select regexp_replace('HH0000HH080300007NY', '^HH|RP', '000', 1,1) from dual;
--select 
--	rtrim(regexp_substr(
--		regexp_replace('BPR*I*57097.9*C*ACH*CCP*01*021300556*DA*320993201765*1141797357**01*021000021*DA*668588267*20170830~', '[*]', 'X*', 1, 0), '[^*|~]+', 1, 3), 'X')
--from dual;
--select rtrim(regexp_substr('foo,,,,bar', '[^,]+',1,2),',') from dual;
--select 
--	rtrim(regexp_substr(regexp_replace('100*C*100*Sabyasachi**45.67', '[*]', 'X*',1,0), '[^*]+',1,6), 'X') from dual;

--select regexp_replace('100**100*Sabyasachi**45.67', '[*]+', 'X*',1,0) from dual;
--select regexp_substr('BPR**57097.9*C*ACH*CCP*01*021300556*DA*320993201765*1141797357**01*021000021*DA*668588267*20170830~*', '(^|\*)([^\*]*)',1,17,'i',2) from dual;
--select rtrim(regexp_substr(regexp_replace('NM1*QE*1*KIHM*RICHARD*S***N*NP48648K~', 
--		 '[*]', 'X*', 1, 0), '[^*|~]+', 1, 9), 'X')
--from dual;
--select regexp_substr('NM1*QE*1*KIHM*RICHARD*S***N*NP48648K~','(^|\*)([^\*]*)',1,10,'i',2) from dual;
--select regexp_substr('ISA*00*          *00*          *ZZ*EMEDNYBAT      *ZZ*A136            *170828*0703*^*00501*240070326*0*P*:~', '(^|\*)([^\*]*)',1,9,'i',2) from dual;
--select 
--	substr(regexp_substr('BPR*I*57097.9*C*ACH*CCP*01*021300556*DA*320993201765*1141797357**01*021000021*DA*668588267*20170830~', '(^|\*)([^\*]*)',1,17,'i',2), 3,6)
--from dual;
--select regexp_substr('ENT*1*2J*EI*HH000000080300007NY', '(^|\*)([^\*]*)',1,5,'i',2) from dual;
--select REGEXP_REPLACE(REGEXP_SUBSTR('ENT*1*2J*EI*HH000000080300007NY', '(^|\*)([^\*]*)',1,5,'i',2),'^HH|RP','000',1,1) from dual;

select substr(REGEXP_SUBSTR('RMR*IK*1718400322066020**0*191.1~', '(^|\*)([^\*|~]*)',1,3,'i',2), 15,16) from dual;
