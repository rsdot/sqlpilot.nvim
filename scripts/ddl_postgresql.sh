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

export PGPASSWORD="$sql_passwd"
export PGCONNECT_TIMEOUT=3

if [[ $(echo "$sql_ddl_objectname" | grep -c '[a-z]') == 0 ]]; then
  sql_ddl_objectname=$(echo "$sql_ddl_objectname" | tr 'A-Z' 'a-z')
fi

cat << EOF > /tmp/tablecount
SELECT COUNT(1)
FROM pg_class c
INNER JOIN pg_namespace n
ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND c.relname = '$sql_ddl_objectname';
EOF

if [[ "$(psql -h $sql_dbsrv -U $sql_login -p $sql_port -d $sql_ddl_dbname -f /tmp/tablecount -t -A)" == "1" ]]; then
  pg_dump -h $sql_dbsrv -U $sql_login -p $sql_port -d $sql_ddl_dbname -s -t "\"$sql_ddl_objectname\"" | perl -0777 -pe 's/.*?(CREATE\s.*)/\1/si; s/\s*\n\-\-.*//mg; s/character varying/varchar/gi'
  exit
fi

cat << EOF > /tmp/procquery
select
  pg_get_functiondef(p.oid) as definition
from pg_proc p
where p.proname = '$sql_ddl_objectname'
EOF

psql -h $sql_dbsrv -U $sql_login -p $sql_port -d $sql_ddl_dbname -f /tmp/procquery -t -A

