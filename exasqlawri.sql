alter session set NLS_DATE_FORMAT='DD-MON-YYYY';
set line 1000
set pagesize 3000
column "PX_SERVERS_EXECS" heading "PX" format 999
column "buffer_gets" heading "MEMORY|READS|(M)" format 999999
column "disk_reads" heading "IO|READS|(M)" format 999999
column "DBTIME" heading "DB|TIME|(Min)" format 9999
column "Cpu" heading "CPU|TIME|(Min)" format 999
column "IO" heading "IO|TIME|(Min)" format 999
column "CLUSTER_WAIT" heading "CLUSTER|TIME|(Min)" format 999
column "APPL_WAIT" heading "APPL|TIME|(Min)" format 9999
column "CONCURRENCY" heading "CONCUR|TIME|(Min)" format 999
column "PLSQL" heading "PLSQLEXEC_TIME|(in Hours)" format 999999.99
column "JAVA" heading "JAVAEXEC_TIME|(in Hours)" format 999999.99
--column "elapsed_time" heading "DB_TIME|(in Minutes)" format 999999.99
--column "Cpu_time" heading "CPU_TIME|(in Minutes)" format 999999.99
column "executions" heading "EXECS" format 9999999
column "parse_calls" heading "PARSE|CALLS" format 9999999
column "rows_processed" heading "ROWS" format 99999999
column schema format a18
column "PHYREAD" heading "PHY|READ|(GB)" format 999999
column "PHYWRITE" heading "PHY|WRITE|(GB)" format 99999
column "INTER" heading "INTER|(GB)" format 99999
column "ELIG" heading "ELIG|(GB)" format 999999
column sqlprof format a30

break on off
break on inst_id skip 1 page 
select * from
(select
 a.instance_number inst_id,
 trunc(b.begin_interval_time) dat,
 parsing_schema_name schema,
 sql_id sql_id,
 sql_profile sqlprof,
 plan_hash_value plan,
 round(sum(ELAPSED_TIME_DELTA)/1000/1000/60,0) DBTIME,
 round(sum(CPU_TIME_DELTA)/1000/1000/60,0) CPU,
 round(sum(IOWAIT_DELTA)/1000/1000/60,0) IO,
 round(sum(CLWAIT_DELTA)/1000/1000/60,0) CLUSTER_WAIT,
 round(sum(APWAIT_DELTA)/1000/1000/60,0) APPL_WAIT,
 round(sum(CCWAIT_DELTA)/1000/1000/60,0) CONCURRENCY,
-- round(sum(BUFFER_GETS_DELTA)/1000,2) buffer_gets,
 round(sum(BUFFER_GETS_DELTA)/1000/1000,2) buffer_gets,
 round(sum(DISK_READS_DELTA)/1000/1000,2) disk_reads,
 round(sum(rows_processed_DELTA),0) rows_processed,
 round(sum(executions_DELTA),0) executions,
 round(sum(PARSE_CALLS_DELTA),0) parse_calls,
 round(sum(PX_SERVERS_EXECS_DELTA),0) PX_SERVERS_EXECS,
round(sum(PHYSICAL_READ_BYTES_DELTA)/1024/1024/1024,2) "PHYREAD",
round(sum(PHYSICAL_WRITE_BYTES_DELTA)/1024/1024/1024,2) "PHYWRITE",
round(sum(IO_OFFLOAD_ELIG_BYTES_DELTA)/1024/1024/1024,2) "ELIG",
round(sum(IO_INTERCONNECT_BYTES_DELTA)/1024/1024/1024,2) "INTER"
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
--and
--a.parsing_schema_name='schema'
and
a.sql_id='&sql_id'
and
 trunc(b.begin_interval_time)>sysdate-90
group by a.instance_number,trunc(b.begin_interval_time)
,parsing_schema_name,sql_id,plan_hash_value,sql_profile)
 order by inst_id,sql_id,2 desc,7 desc;

