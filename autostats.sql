column client_name format a31
column repeat_interval format a76
column window_name format a20
column job_info format a70
column job_status format a10
column job_duration format a15
column job_start_time format a50
column ACTUAL_START_DATE format a60
column last_start_date format a60
column job_name format a25
column duration format a15

set line 1000
set pagesize 1000
set feed off
select status,CLIENT_NAME from DBA_AUTOTASK_CLIENT;
column last_start_date format a37
column next_start_date format a37
column window_name format a16
column repeat_interval format a53
select 
window_name,repeat_interval,enabled,
last_start_date,
next_start_date,duration
--*
from dba_SCHEDULER_WINDOWS where enabled='TRUE' order by 4;


select 
--client_name, JOB_SCHEDULER_STATUS
*
 from DBA_AUTOTASK_CLIENT_JOB
 where client_name='auto optimizer stats collection';

select 
--client_name, JOB_SCHEDULER_STATUS
*
 from DBA_AUTOTASK_CLIENT_JOB
 where client_name='auto space advisor	';

select 
--client_name, JOB_SCHEDULER_STATUS
*
 from DBA_AUTOTASK_CLIENT_JOB
 where client_name='sql tuning advisor';

/*
SELECT client_name, window_name, jobs_created, jobs_started, jobs_completed
FROM dba_autotask_client_history
WHERE client_name like '%stats%';
*/

PROMPT

PROMPT QUERIED FROM DBA_AUTOTASK_JOB_HISTORY
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

select client_name,window_name,job_name,job_Status,job_start_time,job_duration,
job_error
--job_info 
from dba_autotask_job_history where job_start_time>=sysdate-7 and client_name like '%stat%'
order by job_Start_time;

select client_name,window_name,job_name,job_Status,job_start_time,job_duration,job_error
--,job_info 
from dba_autotask_job_history where job_start_time>=sysdate-14 and client_name like '%space%' order by job_Start_time;


select client_name,window_name,job_name,job_Status,job_start_time,job_duration,job_error
--,job_info 
from dba_autotask_job_history where job_start_time>=sysdate-14 and client_name like '%tuning%' order by job_Start_time;

PROMPT
PROMPT QUERIED FROM DBA_SCHEDULER_JOB_RUN_DETAILS
PROMPT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


column job_name format a25
column run_duration format a15
column actual_start_date format a37
column status format a10
column owner for a15
column inst_id format a3
set pagesize 1000


select owner,to_char(instance_id) inst_id,job_name,actual_start_date,run_duration,status,error# from dba_scheduler_job_run_details 
where job_name like 'ORA$AT_SA_SPC%' and actual_Start_date>=sysdate-7 order by 4;
select owner,to_char(instance_id) inst_id,job_name,actual_start_date,run_duration,status,error# from dba_scheduler_job_run_details 
where job_name like 'ORA$AT_OS_OPT_SY%' and actual_Start_date>=sysdate-14 order by 4;

/*
*/