
column name format a30
column path format a60
set line 1000
set pagesize 400
select create_date,group_number,name,total_mb/1024,round(free_mb/1024,0),
--path,
 MOUNT_STATUS,HEADER_STATUS,MODE_STATUS,state,MOUNT_DATE,READ_ERRS,WRITE_ERRS from v$asm_disk where group_number in (0,1,2,3,4,5,6) order by 2,3;