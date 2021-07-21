column parameter format a30
column Session_Value format a30
column Instance_Value format a20
column is_session_modifiable format a20
column is_system_modifiable format a20
SELECT
a.inst_id,
a.con_id,
a.ksppinm "Parameter",
b.ksppstvl "Session_Value",
c.ksppstvl "Instance_Value",
decode(bitand(a.ksppiflg/256,1),1,'TRUE','FALSE') IS_SESSION_MODIFIABLE, 
decode(bitand(a.ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') IS_SYSTEM_MODIFIABLE
FROM
x$ksppi a,
x$ksppcv b,
x$ksppsv c
WHERE
a.indx = b.indx
AND
a.indx = c.indx
AND
a.ksppinm in ('_client_enable_auto_unregister','_emon_send_timeout')
/
