SET HEADER ON
ACCEPT TAB_NAME PROMPT 'ENTER THE TABLE NAME : '
column owner format a20
column segment_name format a30
column table_name format a30

select owner,segment_name,sum(bytes)/1024/1024 from dba_segments where segment_name='&TAB_NAME'  group by owner,segment_name;

select owner,table_name,blocks,num_rows,avg_row_len,last_analyzed,partitioned,temporary,SEGMENT_CREATED,pct_free,pct_used from dba_tables where table_name='&TAB_NAME' ;


ACCEPT OWNER PROMPT 'ENTER THE OWNER : '
break on index_name
column column_name format a35
column index_name format a30
column table_name format a30
column index_owner format a15
select index_owner,table_name,index_name,column_name,column_position from dba_ind_columns where index_owner='&OWNER' and table_name='&TAB_NAME' order by index_name,column_position;


select owner,table_name,column_name,num_nulls,num_distinct,density,last_analyzed,histogram from dba_tab_col_statistics where table_name='&TAB_NAME' and owner='&OWNER' order by num_distinct desc;