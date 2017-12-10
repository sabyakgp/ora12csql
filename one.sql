select ltrim(sys_connect_by_path(warehouse_id, ','), ',')
from oe.warehouses
where connect_by_isleaf = 1
start with warehouse_id = 1
connect by warehouse_id = prior warehouse_id + 1
order by warehouse_id;
