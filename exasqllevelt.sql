/*
SET LONG 1000000
SET LONGCHUNKSIZE 100000
SET LINE 120
set pagesize 50000
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
SET MARKUP HTML ON SPOOL ON PREFORMAT OFF ENTMAP ON -
HEAD "<TITLE>KP - EXADATA VERSIONS</TITLE> -
<STYLE type='text/css'> -
<!-- BODY {background:white;text-align:Left;font-family:calibri;font-size:20px;border:1px solid black;font-weight:bold;color:red} --> -
<!-- TH {background: darkblue;color:white;font-family:calibri;font-size:12px;border:1px solid black;} --> -
<!-- TD {background: lightblue;color:#000000;font-family:calibri;font-size:12px;border:1px solid lightgrey;text-align:justify;} --> -
<!-- TR {valign:top;} --> -
<!-- P {background: white;color:RED} --> -
</STYLE>" -
BODY "color='white'" -
TABLE "BORDER='0' cellspacing='1' cellpadding='1' width='100%' "
set feed on
spool ncmdp24r.html
*/
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
set line 1000
set pagesize 3000
column "PX_SERVERS_EXECS" heading "PX" format 99999999999
column "buffer_gets" heading "MEMORY|READS|(M)" format 999999
column "disk_reads" heading "IO|READS|(M)" format 999999
column "DBTIME" heading "DB|TIME|(Min)" format 99999
column "Cpu" heading "CPU|TIME|(Min)" format 9999
column "IO" heading "IO|TIME|(Min)" format 9999
column "CLUSTER_WAIT" heading "CLUSTER|TIME|(Min)" format 9999
column "APPL_WAIT" heading "APPL|TIME|(Min)" format 9999
column "CONCURRENCY" heading "CONCUR|TIME|(Min)" format 99999
column "PLSQL" heading "PLSQLEXEC_TIME|(in Hours)" format 999999.99
column "JAVA" heading "JAVAEXEC_TIME|(in Hours)" format 999999.99
--column "elapsed_time" heading "DB_TIME|(in Minutes)" format 999999.99
--column "Cpu_time" heading "CPU_TIME|(in Minutes)" format 999999.99
column "executions" heading "EXECS" format 99999999999999
column "parse_calls" heading "PARSE|CALLS" format 99999999999999
column "rows_processed" heading "ROWS" format 999999999
column schema format a20
column "PHYREAD" heading "PHY|READ|(GB)" format 99999999
column "PHYWRITE" heading "PHY|WRITE|(GB)" format 99999
column "INTER" heading "INTER|(GB)" format 99999
column "ELIG" heading "ELIG|(GB)" format 9999999
column "buff_per_exec" heading "Buffers|Per|Exec" format 9999999999
break on off
break on dat skip 1 page 
select * from
(select
 trunc(b.begin_interval_time,'HH24') dat,
 parsing_schema_name schema,
 sql_id sql_id,
 plan_hash_value plan,
 round(sum(ELAPSED_TIME_DELTA)/1000/1000/60,0) DBTIME,
 round(sum(CPU_TIME_DELTA)/1000/1000/60,0) CPU,
 round(sum(IOWAIT_DELTA)/1000/1000/60,0) IO,
 round(sum(CLWAIT_DELTA)/1000/1000/60,0) CLUSTER_WAIT,
 round(sum(APWAIT_DELTA)/1000/1000/60,0) APPL_WAIT,
 round(sum(CCWAIT_DELTA)/1000/1000/60,0) CONCURRENCY,
 round(sum(BUFFER_GETS_DELTA)/1000/1000,2) buffer_gets,
-- round(sum(BUFFER_GETS_DELTA),0)/ round(sum(executions_DELTA),0) buff_per_exec,
 round(sum(DISK_READS_DELTA)/1000/1000,2) disk_reads,
 round(sum(rows_processed_DELTA),0) rows_processed,
 round(sum(executions_DELTA),0) executions,
 round(sum(PARSE_CALLS_DELTA),0) parse_calls,
 round(sum(PX_SERVERS_EXECS_DELTA),0) PX_SERVERS_EXECS,
round(sum(PHYSICAL_READ_BYTES_DELTA)/1024/1024/1024,2) PHYREAD,
round(sum(PHYSICAL_WRITE_BYTES_DELTA)/1024/1024/1024,2) "PHYWRITE",
round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/1024/1024/1024,2) "ELIG",
round(sum(IO_INTERCONNECT_BYTES_DELTA)/1024/1024/1024,2) INTER
--round(((round(sum(PHYSICAL_READ_BYTES_DELTA)/1024/1024/1024/1024,2)-round(sum(IO_INTERCONNECT_BYTES_DELTA)/1024/1024/1024/1024,2))/round(sum(PHYSICAL_READ_BYTES_DELTA)/1024/1024/1024/1024,2))*100,2) "OFFLOAD(%)"
-- round(sum(PLSEXEC_TIME_DELTA)/1000/1000/60/60,0) PLSQL,
-- round(sum(JAVEXEC_TIME_DELTA)/1000/1000/60/60,0) JAVA
from
 DBA_HIST_SNAPSHOT B,
 DBA_HIST_SQLSTAT A
where
 a.snap_id=b.snap_id
and
 a.instance_number=b.instance_number
--and a.parsing_schema_name='&schema'
--and
--a.plan_hash_Value  in ('4233890946','3930062499')
and
 trunc(b.begin_interval_time)>=trunc(sysdate)-30
group by trunc(b.begin_interval_time,'HH24')
,parsing_schema_name,sql_id,plan_hash_value)
where
--inter>100
dbtime>=10
--CONCURRENCY>5
--parse_calls>15000000
--and
--IO>50
--buffer_gets>500
--phywrite>10
--phyread>=100
--CLUSTER_WAIT>10
-- buffer_gets>100
--appl_wait>1
--PX_SERVERS_EXECS>100
--and
--executions=1
 order by 1 desc,
dbtime desc
--phyread desc
--buffer_gets desc
--PX_SERVERS_EXECS desc
;







/*
spool off;
spool ncmdp24r_query.html

select a.schema,a.sql_id,sql_text from
(select
distinct parsing_schema_name schema,
 a.sql_id sql_id
from
 DBA_HIST_SNAPSHOT B,
 DBA_HIST_SQLSTAT A
where
 a.snap_id=b.snap_id
and
 a.instance_number=b.instance_number
and
 trunc(b.begin_interval_time)>sysdate-15 having round(sum(ELAPSED_TIME_DELTA)/1000/1000/60,0)>10
group by trunc(b.begin_interval_time)
,parsing_schema_name,a.sql_id) a,
(Select sql_id,sql_text from dba_hist_sqltext) b
where a.sql_id=b.sql_id order by 1,2
;

spool off;
set markup html off;
*/