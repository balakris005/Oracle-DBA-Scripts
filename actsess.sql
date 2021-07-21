column username format a20
column osuser format a15
column program format a42
column service_name format a25
column machine format a25
column event format a40
column module format a35
set line 10000
set pagesize 10000
break on Instance skip page
select
 inst_id Instance,
   sid,
   serial#,
   username,
round((seconds_in_wait/60),2) Wait_Mins,
   program,
module,
 osuser,
--terminal,
-- server,
   machine,
--process,
sql_id,
event,
blocking_session,
blocking_instance,
   status,
   logon_time,
-- PDML_STATUS, PDDL_STATUS, PQ_STATUS,
--server,
service_name,
action,
module,
   last_call_et/60
from
    gv$session
where
status='ACTIVE' and type='USER' order by 
inst_id,
sql_id
--logon_time
--status='ACTIVE' and type='USER' and machine in ('cto5a127') order by inst_id,sql_id,logon_time
/
