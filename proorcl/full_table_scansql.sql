set serveroutput on
/
drop table t1;
--
create table t1 
tablespace USERS
as
select trunc((level-1)/100) id,
 rpad(level,100) t_pad
 from dual
 connect by level <= 10000;

 
-- 
create index 
t1_idx1 on t1(id)
tablespace USERS;
--
exec dbms_stats.gather_table_stats(user,'t1',method_opt=>'FOR ALL COLUMNS SIZE',cascade=>TRUE);
--
drop table t2;
--
create table t2 as
 select mod(level,100) id,
 rpad(level,100) t_pad
 from dual
 connect by level <= 10000;
--
create index t2_idx1 on t2(id);
--
exec dbms_stats.gather_table_stats(user,'t2',method_opt=>'FOR ALL COLUMNS SIZE',cascade=>TRUE);
--
select trunc((rownum-1)/100) id,
 rpad(rownum,100) t_pad
 from dba_source
 where rownum <= 10000;
--
select mod(rownum,100) id,
 rpad(rownum,100) t_pad
 from dba_source
 where rownum <= 10000;
--
explain plan for select count(*) ct from t2 where id = 1 ;
--
select * from table(dbms_xplan.display(format=>'ALL'));
--
select table_name, num_rows, blocks from user_tables where table_name = 'T1' ;
-- List number of allocated blocks
select blocks from user_segments where segment_name = 'T1';
--List how many blocks contain data
select count(distinct (dbms_rowid.rowid_block_number(rowid))) block_ct from t1 ;
-- List the lowest and highest block numbers for this table
select min(dbms_rowid.rowid_block_number(rowid)) min_blk, max(dbms_rowid.rowid_block_number(rowid)) max_blk from t1 ;
--
delete from t1;
---
commit
--
@C:\Users\sabya\Desktop\Oracle\ora12csql\proorcl\get_space T1
/
select * from sys.t2
/
SELECT * FROM DBA_TABLESPACES;
/
@C:\Users\sabya\Desktop\Oracle\ora12csql\proorcl\get_space
/
set autotrace traceonly