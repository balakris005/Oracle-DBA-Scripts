set line 1000
column host format a25
column mrp heading 'Media|Recovery' format a8
set feed off
--@dat

select 
	lower(a.host_name) "HOST",
	b.name " DB NAME",
	b.open_mode,
	a.thread#,
	a.inst_id,
	upper(a.instance_name) "INSTANCE NAME",
	a.startup_time,
	a.status,
	c.MRP
from 
	gv$instance a, gv$database b,
	(select a.inst_id inst_id, (case when a.inst_id=b.inst_id then 'YES' else 'NO' end) as MRP from (select inst_id from gv$managed_standby where process like 'MRP%') b, (select distinct inst_id from gv$database) a) c
where
	a.inst_id=b.inst_id and b.inst_id=c.inst_id
order by 4;



select 
	lower(a.host_name) "HOST",
	b.name " DB NAME",
	b.open_mode,
	a.thread#,
	a.inst_id,
	upper(a.instance_name) "INSTANCE NAME",
	a.startup_time,
	a.status
from 
	gv$instance a, gv$database b
where
	a.inst_id=b.inst_id
order by 4;

