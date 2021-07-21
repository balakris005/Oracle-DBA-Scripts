set pagesize 10000
set line 1000
set feed off
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
set scan on
ACCEPT SQLID PROMPT 'Enter the SQL_ID :  '
set feed off
break on off
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
set feed on
column start_time format a25
column end_time format a25
column duration format a25
column trunc_date format a20
column plan_value format 999999999999
select
        sql_id,
	--program,
	--machine,
        sql_exec_start,
        --sql_exec_id,
        sql_plan_hash_value plan_value,
min(sample_time) "Start_Time", max(sample_time) "End_Time", max(sample_time)-min(sample_time) "Duration"
from
        dba_hist_active_Sess_history
where
        sql_id='&sqlid' and sql_exec_start is not null and sql_exec_start>sysdate-10
group by sql_id,
--program,machine,
sql_exec_start,sql_exec_id,sql_plan_hash_value order by 4 desc;


break on off
column OPERATION format a38
Column event format a37
--break on sql_exec_start skip 1 page
column sql_plan_options format a20
column OBJ_NAME format a22
column partname format a10
column percent format a25
column sql_id format a13
column pln_id format 9999
column plan format 9999999999
column operation format a35
break on sql_exec_start skip 1 page


select b.sql_id,b.plan,b.sql_exec_start,pln_id,SQL_PLAN_OPERATION||' '||SQL_PLAN_OPTIONS operation,object_name OBJ_NAME,subobject_name PARTNAME,event,
--cnt,total_samp,
round((cnt/total_samp)*100,2)||' %' percent
from
(select object_id,object_name,subobject_name from dba_objects) a,
(select sql_id,SQL_PLAN_HASH_VALUE plan,sql_exec_start,SQL_PLAN_LINE_ID pln_id,SQL_PLAN_OPERATION,SQL_PLAN_OPTIONS,current_obj#,nvl(event,'CPU') event,count(1) cnt from dba_hist_active_Sess_history
where sql_id='&sqlid'
and sql_exec_start is not null and sql_exec_start>sysdate-100
group by
        sql_id,
SQL_PLAN_HASH_VALUE,
        sql_exec_Start,
        sql_plan_line_id,
        sql_plan_operation,
        SQL_PLAN_OPTIONS,
        current_obj#,
        event) b,
(select sql_exec_start,count(1) total_samp from dba_hist_active_Sess_history where sql_id='&sqlid'
and sql_exec_start is not null and sql_exec_start>sysdate-100
group by
        sql_exec_Start) c
where a.object_id=b.current_obj#
and
      b.sql_exec_start=c.sql_exec_start
and round((cnt/total_samp)*100,0)>=0
order by b.sql_exec_start desc,cnt desc;
