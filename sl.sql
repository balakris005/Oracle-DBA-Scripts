 break on off
set pagesize 100
column username format a20
column target format a40
column opname format a34
select
	inst_id,
	sql_id,
	sid,
--	message,
--sql_plan_hash_Value,
	serial#,
	username,
	--message,
	target,
	--target_desc,
--	units,
	--sql_id,
	opname,
--	round((sofar/totalwork)*100,2) "Completed %",
sofar,
totalwork,
	round(time_remaining/60,0) "Time Rem in Min",
	round(elapsed_seconds/60,0) "Elap in Min"
from
	 gv$session_longops
where
	sofar<>totalwork 
order by 2
/

--PROMPT
--PROMPT
--PROMPT


--select a.username,spid,a.sid,a.serial#,B.SQL_ID,context, sofar, totalwork,round(sofar/totalwork*100,2) "%_complete", --message ,time_remaining from v$session_longops a, v$session b,v$process c where totalwork != 0 and sofar <> totalwork and --a.sid=b.sid and b.paddr=c.addr;

