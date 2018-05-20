-- Running SQLLDR in Express Mode

drop table dept purge;

create table dept
  ( deptno  number(2) constraint dept_pk primary key,
    dname   varchar2(14),
    loc     varchar2(13)
)
/
