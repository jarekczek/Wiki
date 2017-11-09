set linesize 30000;
set pagesize 10000;
set serveroutput on;

declare x varchar2(20000);
begin
  for i in 1..3 loop
    x := concat(x, '1234567890');
    DBMS_OUTPUT.PUT_LINE(concat('x:', x));
  end loop;
end;
/

column owner format a3;
select * from all_tables where rownum < 20
  and tablespace_name not in ('SYSTEM', 'SYSAUX')
;

quit;
