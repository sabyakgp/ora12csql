select t.table_name||'.'||i.index_name idx_name, i.clustering_factor, t.blocks, t.num_rows
from user_indexes i, user_tables t
where i.table_name = t.table_name
and t.table_name in ('T1','T2')
order by t.table_name, i.index_name;
/
select a.index_name, b.num_rows, b.blocks, a.clustering_factor
from user_indexes a, user_tables b
where index_name in ('T2_IDX1', 'T1_IDX1' )
and a.table_name = b.table_name;
/
select * from dba_objects where object_name = 't1_idx1'
/
select sum(cluf_ct)
from
(
select 
    id, 
    trim(t_pad) t_pad,
    blk_no, 
    lag (blk_no,1,blk_no) over (order by id) prev_blk_no,
    case when blk_no != lag (blk_no,1,blk_no) over (order by id) or rownum = 1
        then 1
    else null
    end cluf_ct
from (
select id, 
       t_pad,
       dbms_rowid.rowid_block_number(rowid) blk_no
from 
    t1
where 
    id is not null
order by id
)
);
/
select 
count(distinct (block_no))
from
(
select 
    t.rowid , (select file_name from dba_data_files where file_id = dbms_rowid.rowid_to_absolute_fno(t.rowid, user, 'T1')) filen,
    dbms_rowid.rowid_block_number(t.rowid) block_no,
    dbms_rowid.rowid_row_number(t.rowid) row_no
from   
    t1 t
);
/
exec dbms_stats.set_table_prefs(user, 'T2', pname=>'TABLE_CACHED_BLOCKS', pvalue=>255);
/
exec dbms_stats.gather_table_stats(user,'T2') ;
/
select 
    t.table_name||'.'||i.index_name idx_name,
    i.clustering_factor, t.blocks, t.num_rows
from 
    user_indexes i, user_tables t
where 
    i.table_name = t.table_name
    and t.table_name in ('T1','T2')
order by t.table_name, i.index_name;
/
set autotrace traceonly explain
/
select * from hr.employees where employee_id = 100;