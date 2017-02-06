drop table t1;
--
create table t1 as
select trunc((level-1)/100) id,
 rpad(level,100) t_pad
 from dual
 connect by level <= 10000;
-- 
create index t1_idx1 on t1(id);
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
select blocks from user_segments where segment_name = 'T2';
--List how many blocks contain data
select count(distinct (dbms_rowid.rowid_block_number(rowid))) block_ct from t2 ;
-- List the lowest and highest block numbers for this table
select min(dbms_rowid.rowid_block_number(rowid)) min_blk, max(dbms_rowid.rowid_block_number(rowid)) max_blk from t2 ;
--
delete from t2 where id = 1 ;
---
commit
--
@C:\Users\sabya\Desktop\Oracle\ora12csql\proorcl\get_space t2
/
select * from sys.t2
/
declare
 l_tabname varchar2(30) := 'T2';
 l_fs1_bytes number;
 l_fs2_bytes number;
 l_fs3_bytes number;
 l_fs4_bytes number;
 l_fs1_blocks number;
 l_fs2_blocks number;
 l_fs3_blocks number;
 l_fs4_blocks number;
 l_full_bytes number;
 l_full_blocks number;
 l_unformatted_bytes number;
 l_unformatted_blocks number;
begin
 dbms_space.space_usage(
 segment_owner => user,
 segment_name => l_tabname,
 segment_type => 'TABLE',
 fs1_bytes => l_fs1_bytes,
 fs1_blocks => l_fs1_blocks,
 fs2_bytes => l_fs2_bytes,
 fs2_blocks => l_fs2_blocks,
 fs3_bytes => l_fs3_bytes,
 fs3_blocks => l_fs3_blocks,
 fs4_bytes => l_fs4_bytes,
 fs4_blocks => l_fs4_blocks,
 full_bytes => l_full_bytes,
 full_blocks => l_full_blocks,
 unformatted_blocks => l_unformatted_blocks,
 unformatted_bytes => l_unformatted_bytes
 );
 dbms_output.put_line('0-25% Free = '||l_fs1_blocks||' Bytes = '||l_fs1_bytes);
 dbms_output.put_line('25-50% Free = '||l_fs2_blocks||' Bytes = '||l_fs2_bytes);
 dbms_output.put_line('50-75% Free = '||l_fs3_blocks||' Bytes = '||l_fs3_bytes);
 dbms_output.put_line('75-100% Free = '||l_fs4_blocks||' Bytes = '||l_fs4_bytes);
 dbms_output.put_line('Full Blocks = '||l_full_blocks||' Bytes = '||l_full_bytes);
end;