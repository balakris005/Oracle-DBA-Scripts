column status format a30
column operation format a10
select 
	operation,
	row_level,
	row_type,
--command_id,
	object_type TYPE,
	to_char(start_time,'DD-MON-YYYY HH24:MI:SS') starttime, 
	to_char(end_time,'DD-MON-YYYY HH24:MI:SS') endtime,
	status,
	round(mbytes_processed/1024,2) "SIZE GB",output_Device_type "DEVICE TYPE" 
from 
	v$rman_Status a where start_time>sysdate-40
--and operation='BACKUP' 
--and operation='DELETE'
and operation in ('BACKUP BACKUPSET','INCREMENTAL BACKUP RESTORE','VERIFYING FILES FOR RECOVERY','BACKUP COPYROLLFORWARD','BACKUP')
--and object_type not in ('ARCHIVELOG','CONTROLFILE','SPFILE')
and ( object_type in ('DB FULL','DB INCR','ARCHIVELOG','CONTROL FILE','PFILE') or object_type is null)
 order by start_time desc;