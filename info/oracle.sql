-- backup and restore using rman:
-- https://logicalread.com/backup-restore-scripts-rman-oracle-mc05/#.WnDlFHndggA

set linesize 30000;
set pagesize 10000;
set serveroutput on;

declare x varchar2(20000);
  sqlId varchar(2000);
begin
  for i in 1..3 loop
    x := concat(x, '1234567890');
    DBMS_OUTPUT.PUT_LINE(concat('x:', x));
    if (v_i.correct_repr is null) then
      DBMS_OUTPUT.PUT_LINE('ERROR nieprawidlowy repr, przerywamy dla tej  umowy.');
      continue;
    end if;
  end loop;

	select sql_id into sqlId from v$sql where sql_text like '%RESULT not in (''zak_sys''%';
end;
/

column owner format a3;
select * from all_tables where rownum < 20
  and tablespace_name not in ('SYSTEM', 'SYSAUX')
;

quit;


alter session set current_schema = jarek;

-- znajdz nieciaglosci w id (lead/lag)
select e.employee_id as empid,
  lead(employee_id, 1, null) over (order by employee_id asc) as nast
from hr.employees e

-- ostatnie query
select to_char(sql.LAST_ACTIVE_TIME, 'yy-mm-dd hh24:mi:ss')
, sql.* from v$sql sql
order by sql.LAST_ACTIVE_TIME desc
;

-- aktywne sesje i sql query
select se.wait_class, se.state, se.TIME_REMAINING_MICRO
, se.last_call_et /* liczba sekund trwania sesji (dla stanu active) */
, sql.elapsed_time / 1000 / sql.EXECUTIONS
, sql.LAST_ACTIVE_TIME, se.SQL_EXEC_START
, sql.LAST_ACTIVE_TIME - se.SQL_EXEC_START
, sql.sql_text, se.* from v$session se
--join v$sql sql on se.SQL_HASH_VALUE = sql.HASH_VALUE
join v$sql sql on se.SQL_id = sql.sql_id
where se.program = 'sqlplus.exe'
order by se.LOGON_TIME desc
;

-- wyszukanie sql po tekscie:
select distinct(s1.sql_id)
from v$sqltext s1, v$sqltext s2
where s1.sql_id = s2.sql_id and s2.PIECE = s1.piece + 1
and concat(s1.sql_text, s2.sql_text) like '%HOGA%'
;


-- index hint
select /*+ index(a IDX_APP_APP_NUMBER) index(mc IDX_MOK_CALL_APPID_CT)*/ a.application_number, a.application_date, a.PRODUCT, a.APPLICATION_TYPE, api.sap, mc.*
from mok.mok_call mc, mok.application a, mok.api 

--How to add a hint to ORACLE query without touching its text
--http://intermediatesql.com/oracle/how-to-add-a-hint-to-oracle-query-without-touching-its-text/
--How to fix CPU usage problem in 12c due to DBMS_FEATURE_AWR
--http://www.ludovicocaldara.net/dba/cpu-usage-12c-dbms_feature_awr/
--https://stackoverflow.com/questions/14043668/oracle-updates-inserts-stuck-db-cpu-at-100-concurrency-high-sqlnet-wait-mes
--http://www.dba-oracle.com/t_sql_causing_high_cpu.htm (v$sqlarea)

-- mierzenie czasu wykonania danego query {{{
set linesize 30000;
set pagesize 10000;
set serveroutput on;

declare sqlId varchar(2000);
  lastActive1 timestamp;
  lastActive2 timestamp;
	c number;
begin

DBMS_OUTPUT.PUT_LINE('dzien dobry');
select current_timestamp into lastActive1 from v$sql where rownum < 2;
DBMS_OUTPUT.PUT_LINE(concat('teraz: ', lastActive1));

c := 0;
FOR v_rec IN (
	select tutaj_nasze_query
) LOOP
  c := c + 1;
END LOOP;
DBMS_OUTPUT.PUT_LINE(concat('liczba rekordow: ', c));

select current_timestamp into lastActive2 from v$sql where rownum < 2;

DBMS_OUTPUT.PUT_LINE(concat('duration: ', lastActive2 - lastActive1));

end;
/

--select * from v$sql where sql_id = '269bxvthmfwq1';

quit;
}}}

alter sequence dict_seq increment by 1;
select dict_seq.nextval from dual;

-- regex
where REGEXP_LIKE(MNG_IND_CALENDAR_ENTRY_ID, '^[0-9]+$')

-- rank - get top records {{{
select * from (
  select a.agreement_number, crz.crz_number, crz.last_modified_time,
  rank() over (partition by a.id order by crz.last_modified_time) rnk
  from AGREEMENT a
  left join tabcrz crz on crz.AGREEMENT_ID = a.id
) where rnk = 1
;
}}}

-- disk usage {{{
select ta.table_name, ta.blocks*8/1024, TA.* from all_tables ta
where ta.blocks is not null
order by ta.blocks desc, ta.table_name
;

select lobs.table_name, se.bytes / 1000000000.0, se.* from dba_segments se
left join dba_lobs lobs on se.SEGMENT_NAME = lobs.SEGMENT_NAME
WHERE se.OWNER='PDPDB' and lobs.owner='PDPDB'
ORDER BY bytes desc

-- dba_extents
;
}}}

-- unblock user:
sudo su -
su - oracle
sqlplus / as sysdba
alter user JACZ_MTG identified by "new password";
alter user JACZ_MTG account unlock;

-- convert interval to int
-- move seconds to days, then extract them as days
extract(day from (endtime - starttime)*60*60*24)

-- partitions
select * from all_tab_partitions
where table_name = 'MYTABLE'
order by partition_name desc
;
select * from mytable partition(ILOG_PD20191104)
;

-- change sequence value

revoke select on mok.APPLICATION_NUMBER_SEQ from mokuser;
select mok.APPLICATION_NUMBER_SEQ.nextval from dual;
select mok.APPLICATION_NUMBER_SEQ.currval from dual;
alter sequence mok.APPLICATION_NUMBER_SEQ increment by -(value returned - 1) nocache;
select mok.APPLICATION_NUMBER_SEQ.nextval from dual;
alter sequence mok.APPLICATION_NUMBER_SEQ increment by 1 ???nocache???;
grant select on mok.APPLICATION_NUMBER_SEQ to mokuser;

--table record

declare
TYPE tabRecType is record
 (
    covId number
 );
type tabType is table of tabRecType;
tab tabType;
begin
	tab := tabType();
  tab.extend; tab(tab.count).covId := 137669787688273428697127409643349389337;
	FOR i IN 1..tab.count loop
    dbms_output.put_line('processing: ' || tab(i));
  END LOOP;
  commit;
end;
/
EXIT 0; 

-- active sessions
select SE.WAIT_CLASS, se.status, se.event, 'alter system kill session ''' || se.sid || ',' || serial# || ''';', se.osuser , se.* from v$session se
where se.osuser = 'UY63FU'
AND se.state = 'WAITING'
;
