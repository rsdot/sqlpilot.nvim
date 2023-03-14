#!/usr/bin/env bash

shopt -u nocasematch

while getopts h:p:d:U:P:m:o:f: option
do
  case "${option}"
  in
    h) sql_dbsrv=${OPTARG};;
    p) sql_port=${OPTARG};;
    d) sql_ddl_dbname=${OPTARG};;
    U) sql_login=${OPTARG};;
    P) sql_passwd=${OPTARG};;
    m) sql_ddl_schemaname=${OPTARG};;
    o) sql_ddl_objectname=${OPTARG};;
    f) sql_ddl_objectfile=${OPTARG};;
    *) ;;
  esac
done

export LD_LIBRARY_PATH=$HOME/src/oracle/instantclient_19_6

$LD_LIBRARY_PATH/sqlplus -S $sql_login/$sql_passwd@$sql_dbsrv <<EOF > /tmp/$sql_ddl_objectname.sql
set pagesize 10000
set linesize 32767
set long 50000
set wrap on
set heading off
set feedback off
ALTER SESSION SET NLS_COMP = LINGUISTIC;
ALTER SESSION SET NLS_SORT = BINARY_CI;
ALTER SESSION SET CURRENT_SCHEMA = $sql_ddl_dbname;

SELECT DBMS_METADATA.GET_DDL(obj.OBJECT_TYPE, obj.OBJECT_NAME, obj.OWNER)
FROM all_objects obj
WHERE obj.owner = '$sql_ddl_dbname'
  AND obj.OBJECT_NAME = '$sql_ddl_objectname'
  AND obj.OBJECT_TYPE NOT IN ('PACKAGE BODY');

SELECT DBMS_METADATA.GET_DDL('INDEX', ind.index_name, ind.owner)
FROM all_indexes ind
INNER JOIN all_tables tab
ON ind.owner = tab.owner AND ind.table_name = tab.table_name
WHERE ind.owner = '$sql_ddl_dbname'
  AND ind.table_owner = '$sql_ddl_dbname'
  AND ind.table_name = '$sql_ddl_objectname'
ORDER BY ind.index_name;

SELECT DBMS_METADATA.GET_DDL('TRIGGER', tri.trigger_name, tri.owner)
FROM all_triggers tri
INNER JOIN all_tables tab
ON tri.owner = tab.owner AND tri.table_name = tab.table_name
WHERE tri.owner = '$sql_ddl_dbname'
  AND tri.table_owner = '$sql_ddl_dbname'
  AND tri.table_name = '$sql_ddl_objectname'
ORDER BY tri.trigger_name;
exit
EOF

script_path="$(dirname "$0")"

if [ $(grep 'CREATE TABLE' /tmp/$sql_ddl_objectname.sql | wc -l) -eq 1 ]; then
  python3 "$script_path"/ddlscriptout.py $sql_ddl_dbname /tmp/$sql_ddl_objectname.sql
else
  cat /tmp/$sql_ddl_objectname.sql
fi

