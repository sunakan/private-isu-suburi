#!/bin/bash -eux

#
# MySQLのインデックス群を表示
#
# INPUT:
# - tmp/app-servers
# OUTPUT:
# - tmp/mysql-users
# - tmp/mysql-databases
#

readonly INPUT_FILE="tmp/app-servers"
readonly SERVER=$(head -n 1 ${INPUT_FILE})

echo "-------[ 📊MySQL Info: ${SERVER} ]"

#
# User
#
echo '----[ User 一覧 ]'
ssh -n ${SERVER} "sudo mysql -e 'SELECT CONCAT_WS(\"@\", User, Host) FROM mysql.user;'" | tee tmp/mysql-users

#
# DB
#
echo ''
echo '----[ DB 一覧 ]'
ssh -n ${SERVER} "sudo mysql -e 'SHOW DATABASES;'" | tee tmp/mysql-databases

#
# DB Tables
#
echo ''
echo '----[ DB(grep isu) のDDL一覧 ]'
while read db; do
  ssh -n ${SERVER} "sudo mysqldump -u root --no-data ${db}" | tee tmp/mysql-db-ddl.${db}.sql
done < <(cat tmp/mysql-databases | grep isu)

#
# KEY一覧
#
echo ''
while read file; do
  echo "----[ ${file} ]"
  cat ${file} | grep -v '\/\*' | grep -E '(CREATE TABLE|KEY)'
done < <(ls -1 tmp/mysql-db-ddl.*.sql)
