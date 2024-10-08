\c xxx connect to xxx database
\l list databases
\dn show schemas
\dt list tables - show nothing
select table_name from information_schema.tables;
\du list users

ALTER USER user_name WITH PASSWORD 'new_password';

--schemas
select * from pg_catalog.pg_namespace

--grants
SELECT * FROM information_schema.role_table_grants order by table_name, grantee, privilege_type;

set search_path to xxx, yyy;

select * from pg_catalog.pg_tables
order by tablename;

select * from pg_catalog.pg_default_acl order by defaclobjtype;

--date literal
timestamp '2024-09-13'
