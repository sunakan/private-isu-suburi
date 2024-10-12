#!/bin/bash -eux

#
# ログをキレイにして再起動
#
# INPUT:
# - tmp/app-servers
# OUTPUT:
# - 特に無し
#
readonly INPUT_FILE="tmp/app-servers"

#
# Nginx
#
echo "-------[ 🧹Clean nginx logs ]"
while read server; do
  ssh -n ${server} "sudo mv /var/log/nginx/error.log /var/log/nginx/error.log.old && sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.old && sudo systemctl reload nginx"
  echo "${server}: Clean logs and restart nginx🚀"
done < ${INPUT_FILE}

#
# MySQL
#
echo "-------[ 🧹Clean mysql logs ]"
while read server; do
  ssh -n ${server} "sudo -u mysql mv /var/log/mysql/error.log /var/log/mysql/error.log.old && sudo -u mysql mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.old && sudo systemctl restart mysql"
  echo "${server}: Clean logs and restart mysql🚀"
done < ${INPUT_FILE}
