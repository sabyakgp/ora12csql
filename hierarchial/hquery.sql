/*
with t1(id, parent_id) as
(
select id,
parent_id
from tab1
where parent_id is null
union all
select t2.id,
t2.parent_id
from
tab1 t2, t1
where t2.parent_id = t1.id
)
--search breadth first by id set order1
search depth first by id set order1
select id, parent_id from t1
order by order1
;
*/
prompt Connect BY and Starts With
select 

