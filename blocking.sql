### Blocking Sessions
set linesize 300 
select B.USERNAME ||' ('||B.SID||','||B.SERIAL#||',@'||B.INST_ID||') is Currently '||B.STATUS||' for last '||B.LAST_CALL_ET||' Sec and it''s BLOCKING user '|| W.USERNAME|| ' ('|
|W.SID||','||W.SERIAL#||',@'||W.INST_ID||')' from 
(select INST_ID,SID,SERIAL#,USERNAME,STATUS,BLOCKING_INSTANCE,BLOCKING_SESSION, LAST_CALL_ET from gv$session where BLOCKING_SESSION >0) W, 
(select INST_ID,SID,SERIAL#,USERNAME,STATUS,LAST_CALL_ET from gv$session ) B 
where W.BLOCKING_INSTANCE=B.INST_ID and W.BLOCKING_SESSION=B.SID; 

###Kill_blocking_Session
set serveroutput on 
set feedback off 
set linesize 300 
 
declare 
blockcount number; 
sqlreport varchar(3000); 
sqloutput varchar(5000); 
v_rec varchar(3000); 
 
cursor blk_curs is select B.USERNAME BUSER,B.SID BSID,B.SERIAL# BSERIAL,B.INST_ID BID,B.STATUS BSTAT,B.LAST_CALL_ET BLAST,W.USERNAME WUSER,W.SID WSID,W.SERIAL# WSERIAL,W.INST_ID WID  
from (select INST_ID,SID,SERIAL#,USERNAME,STATUS,BLOCKING_INSTANCE,BLOCKING_SESSION, LAST_CALL_ET from gv$session where BLOCKING_SESSION >0) W,  
(select INST_ID,SID,SERIAL#,USERNAME,STATUS,LAST_CALL_ET from gv$session ) B  
where W.BLOCKING_INSTANCE=B.INST_ID and W.BLOCKING_SESSION=B.SID and B.username not in ('SYS','SYSTEM','DBSNMP','RMAN'); 
cursor distval is select distinct B.SID CSID, B.USERNAME CUSER from (select INST_ID,SID,SERIAL#,USERNAME,STATUS,BLOCKING_INSTANCE,BLOCKING_SESSION, LAST_CALL_ET  
from gv$session where BLOCKING_SESSION >0) W, (select INST_ID,SID,SERIAL#,USERNAME,STATUS,LAST_CALL_ET from gv$session ) B  
where W.BLOCKING_INSTANCE=B.INST_ID and W.BLOCKING_SESSION=B.SID and B.username not in ('SYS','SYSTEM','DBSNMP','RMAN'); 
cursor killcurs(v in varchar, b in number) is select SID ,serial# SERIAL,inst_id ,username ,to_char(logon_time,'''DD-MON-YYYY HH24-MI-SS''') OTIME,event,status ,machine ,round(LAST_CALL_ET/60,2) OMIN  
FROM gv$session where username is not null and username=v and sid=b order by inst_id; 
begin 
DBMS_OUTPUT.put_line('Checking for blocking sessions on this database'); 
DBMS_OUTPUT.put_line('-----------------------------------------------');
select count(*) into blockcount from (select * from gv$session where BLOCKING_SESSION >0) W, 
(select * from gv$session ) B where W.BLOCKING_INSTANCE=B.INST_ID and W.BLOCKING_SESSION=B.SID and B.username not in ('SYS','SYSTEM','DBSNMP','RMAN'); 
	IF blockcount > 0 THEN 
		DBMS_OUTPUT.put_line('Found blocking sessions -> Fetching report for the same'); 
		DBMS_OUTPUT.put_line('-------------------------------------------------------'); 
		for v_rec in blk_curs LOOP 
		dbms_output.put_line(v_rec.BUSER ||' ('||v_rec.BSID||','||v_rec.BSERIAL||',@'||v_rec.BID||') is Currently '||v_rec.BSTAT||' for last '||v_rec.BLAST||' Sec and it''s BLOCKING user '|| v_rec.WUSER||' ('||v_rec.WSID||','||v_rec.WSERIAL||',@'||v_rec.WID||')'); 
		end loop; 
		DBMS_OUTPUT.put_line('-'); 
		DBMS_OUTPUT.put_line('-'); 
		DBMS_OUTPUT.put_line('Further details on blocking sessions -> includes kill script of blocking session'); 
		DBMS_OUTPUT.put_line('--------------------------------------------------------------------------------'); 
		for v_rec2 in distval LOOP 
			for v_rec3 in killcurs(v_rec2.CUSER, v_rec2.CSID) loop 
			dbms_output.put_line('alter system kill session '''||v_rec3.SID|| ',' || v_rec3.SERIAL||',@'||v_rec3.inst_id|| ''' immediate; '||v_rec3.username||' '||v_rec3.OTIME||' '|| v_rec3.event||' '||v_rec3.status||' '||v_rec3.machine||' '||v_rec3.OMIN); 
			end loop; 
		end loop; 
		DBMS_OUTPUT.put_line('-'); 
		DBMS_OUTPUT.put_line('-'); 
	ELSE 
		DBMS_OUTPUT.put_line('-'); 
		DBMS_OUTPUT.put_line('-'); 
		DBMS_OUTPUT.put_line('Hurrey !!! No blocking sessions found'); 
		DBMS_OUTPUT.put_line('-'); 
		DBMS_OUTPUT.put_line('-'); 
	END IF; 
END; 
/ 


###Blocking_session_event
set linesize 300 
set pagesize 100 
col machine for a50 
col event for a50 
col username for a25 
select inst_id,sid,serial#,username,event,status,sql_id,BLOCKING_SESSION,machine from gv$session 
where event like '%lock%' or event like '%latch%' or event like '%buffer%' or event='latch: row cache objects' or event='enq: TM - contention' 
or event='enq:_TX_-_index_contention' 
and type!='BACKGROUND' order by 1;


####Objects involved in Blocking Lock
col ltype for a30 
col holder for a25 
col waiter for a25 
set linesize 300 
col object_name for a30
SELECT /*+ RULE */ 
         DISTINCT o.object_name,    sh.username 
                               || '(' 
                               || sh.sid 
                               || ')' Holder, 
                   sw.username 
                || '(' 
                || sw.sid 
                || ')' Waiter, 
                DECODE ( 
                   lh.lmode, 
                   1, 'NULL', 
                   2, 'row share', 
                   3, 'row exclusive', 
                   4, 'share', 
                   5, 'share row exclusive', 
                   6, 'exclusive' 
                ) ltype 
           FROM all_objects o, gv$session sw, gv$lock lw, gv$session sh, gv$lock lh 
          WHERE lh.id1 = o.object_id 
            AND lh.id1 = lw.id1 
            AND sh.sid = lh.sid 
            AND sw.sid = lw.sid 
            AND sh.lockwait IS NULL 
            AND sw.lockwait IS NOT NULL 
            AND lh.TYPE = 'TM' 
            AND lw.TYPE = 'TM';
			
			
###Find_SID_PID_for_Table_Lock			
set linesize 300 
col object for a30 
 
SELECT  l.inst_id,   
SUBSTR(L.ORACLE_USERNAME,1,8) ORA_USER,    
SUBSTR(L.SESSION_ID,1,5) SID,   
S.serial#,   
SUBSTR(O.OWNER||'.'||O.OBJECT_NAME,1,40) OBJECT, P.SPID OS_PID,   
DECODE(L.LOCKED_MODE,   0,'NONE',   
1,'NULL',   
2,'ROW SHARE',   
3,'ROW EXCLUSIVE',   
4,'SHARE',   
5,'SHARE ROW EXCLUSIVE',   
6,'EXCLUSIVE',   
NULL) LOCK_MODE   
FROM    sys.GV_$LOCKED_OBJECT L   
, DBA_OBJECTS O   
, sys.GV_$SESSION S   
, sys.GV_$PROCESS P   
WHERE     L.OBJECT_ID = O.OBJECT_ID   
  and     l.inst_id = s.inst_id   
  AND     L.SESSION_ID = S.SID   
  and     s.inst_id = p.inst_id   
  AND     S.PADDR = P.ADDR(+)   
order by l.inst_id; 

###Table_Lock_info
SET ECHO        OFF 
SET FEEDBACK    6 
SET HEADING     ON 
SET LINESIZE    256 
SET PAGESIZE    50000 
SET TERMOUT     ON 
SET TIMING      OFF 
SET TRIMOUT     ON 
SET TRIMSPOOL   ON 
SET VERIFY      OFF 
 
CLEAR COLUMNS 
CLEAR BREAKS 
CLEAR COMPUTES 
 
COLUMN sid                FORMAT 999999     HEADING 'SID' 
COLUMN serial_id          FORMAT 99999999   HEADING 'Serial ID' 
COLUMN oracle_username    FORMAT a18        HEADING 'Oracle User' 
COLUMN logon_time         FORMAT a18        HEADING 'Login Time' 
COLUMN owner              FORMAT a20        HEADING 'Owner' 
COLUMN object_type        FORMAT a16        HEADING 'Object Type' 
COLUMN object_name        FORMAT a25        HEADING 'Object Name' 
COLUMN locked_mode        FORMAT a11        HEADING 'Locked Mode' 
 
prompt  
prompt +----------------------------------------------------+ 
prompt | Table Locking Information                          | 
prompt +----------------------------------------------------+
SELECT 
    a.session_id                    sid 
  , c.serial#                       serial_id 
  , a.oracle_username               oracle_username 
  , TO_CHAR( 
      c.logon_time,'mm/dd/yy hh24:mi:ss' 
    )                               logon_time 
  , b.owner                         owner 
  , b.object_type                   object_type 
  , b.object_name                   object_name 
  , DECODE( 
        a.locked_mode 
      , 0, 'None' 
      , 1, 'Null' 
      , 2, 'Row-S' 
      , 3, 'Row-X' 
      , 4, 'Share' 
      , 5, 'S/Row-X' 
      , 6, 'Exclusive' 
    )                               locked_mode 
FROM  
    v$locked_object a 
  , dba_objects b 
  , v$session c 
WHERE 
      a.object_id  = b.object_id 
  AND a.session_id = c.sid 
ORDER BY 
    b.owner 
  , b.object_type 
  , b.object_name; 
  



/*
###Find sql by sid
set verify off lines 130 pages 1000 
select b.sid,b.serial#,b.machine,b.terminal,b.username,b.status,b.osuser,b.sql_id,a.sql_text      from v$sqlarea a,v$session b where a.address = b.sql_address and   a.hash_value = b.sql_hash_value and   b.sid = &sid;  

*/

###killbysid
set linesize 300 
col a for a60 
col machine for a20 
col username for a20 
col terminal for a20 
col program for a20 
col osuser for a20
SELECT 'alter system kill session ''' || s.sid || ',' || s.SERIAL# || ',@' ||s.inst_id || ''' immediate;' a, 
s.INST_ID,
s.program, 
to_char(s.logon_time,'DD-MON-YYYY HH24:MI:SS'), 
s.status, 
s.username, 
s.machine, 
s.program, 
s.osuser, 
'kill -9 ' || p.SPID 
FROM gv$session s, gv$process p 
WHERE ( (p.addr(+) = s.paddr)) and s.username is not null and s.username not in ('SYSTEM','DBSNMP','RMAN') 
AND s.sid = &sid; 


alter system kill session '4742,49650,@1'