Rem Add virtual to column storing hash value to table
alter table hr.dept add hash as (standard_hash(dname||loc, 'SHA512'));