set pagesize 1000
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24';
select * from 
(select 
	Thread#,
	 dest_id,
         to_date(First_time,'DD-MON-YYYY HH24')"DATE",
         count(1) NUMBER_OF_LOGS,
         round((sum(blocks)*min(block_size))/1024/1024/1024,2) "SIZE (IN GB)"
from 
         v$archived_log 
where
	trunc(first_time)>=trunc(sysdate-15)
and
	thread# in (1,2,3,4)
and
	dest_id=1
group by 
	Thread#,
	dest_id,
        to_date(first_time,'DD-MON-YYYY HH24') 
order by 
	1,2,3) 
--where NUMBER_OF_LOGS>=100
;