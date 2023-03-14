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

export MYSQL_PWD="$sql_passwd"

mysqldump --ssl-mode=DISABLED -h $sql_dbsrv -u $sql_login -P $sql_port --compact --no-data --skip-set-charset --skip-opt --skip-quote-names --set-gtid-purged=OFF $sql_ddl_dbname "$sql_ddl_objectname" 2> /dev/null

