set echo off;
conn C##report_user/report123@nzepdb062xm.nndc.kp.org:1521/SA360P1R.nndc.kp.org
set sqlprompt SA360>
set echo on;
set timing on;
set time on;
set history on
show con_name;
set line 10000