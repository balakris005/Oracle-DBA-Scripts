column value_string  format a30

column name format a10

select name,datatype_string,VALUE_STRING,count(1) from dba_hist_sqlbind where sql_id='&sql_id' group by name,datatype_string,VALUE_STRING order by 1,3 desc;


select name,datatype_string,VALUE_STRING,count(1) from gv$sql_bind_capture where sql_id='&sql_id' group by name,datatype_string,VALUE_STRING order by 1,3 desc;
