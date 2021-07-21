@pdb
select inst_id,decode(background,'1','BG PROCESS','USER PROCESS') "PROCESS",round(sum(PGA_USED_MEM)/1024/1024,0) "USED_MB",round(sum(PGA_ALLOC_MEM)/1024/1024,0) "ALLOC_MB"
from gv$process group by inst_id,decode(background,'1','BG PROCESS','USER PROCESS') order by 2,1;

select a.inst_id,type,username,sid,serial#,program,pname,PGA_USED_MB, PGA_ALLOC_MB from
(select sid,serial#,inst_id,username,paddr,type from gv$session) a,
(SELECT inst_id,spid,PROGRAM,pname, PGA_USED_MEM/1024/1024 PGA_USED_MB, PGA_ALLOC_MEM/1024/1024 PGA_ALLOC_MB, 
PGA_FREEABLE_MEM FREEABLE, PGA_MAX_MEM,addr
FROM gV$PROCESS where PGA_USED_MEM/1024/1024 >250 ) b
where
	a.paddr=b.addr
and
	a.inst_id=b.inst_id  order by a.inst_id,type desc;