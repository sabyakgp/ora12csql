--Decoding rowid: A row is identified by file name, block name and row id
select e.rowid,
 (select file_name
 from dba_data_files
 where file_id = dbms_rowid.rowid_to_absolute_fno(e.rowid, 'HR', 'EMPLOYEES')) filen,
 dbms_rowid.rowid_block_number(e.rowid) block_no,
 dbms_rowid.rowid_row_number(e.rowid) row_no
 from hr.employees e
 where e.email = 'SKING' ;
/
select * from dba_data_files;
/