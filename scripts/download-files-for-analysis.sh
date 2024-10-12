#!/bin/bash -eux

#
# ログや設定など分析用のファイル群をダウンロード
#
# INPUT:
# - tmp/app-servers
# OUTPUT:
# - tmp/analysis/yyyy-mm-ddTHH:MM:SS+09:00/
# - シンボリックリンク: tmp/analysis/latest/ -> tmp/logs/yyyy-mm-ddTHH:MM:SS+09:00/
#
readonly CURRENT_TIME="$(TZ='Asia/Tokyo' date +"%Y-%m-%dT%H:%M:%S%z")"
readonly OUTPUT_DIR_PATH="tmp/analysis/${CURRENT_TIME}"
readonly INPUT_FILE="tmp/app-servers"

#
# バリデーション
#
if [ ! -f ${INPUT_FILE} ]; then
  echo "Not found: ${INPUT_FILE}"
  exit 1
fi

#
# ディレクトリ作成
#
mkdir -p "${OUTPUT_DIR_PATH}"

#
# Nginx
# - /etc/nginx/nginx.conf
# - /etc/nginx/sites-available/isucon.conf
# - /var/log/nginx/access.log
#
echo "-------[ ⬇️Download nginx files for analysis ]"
while read server; do
  rsync -az ${server}:/etc/nginx/nginx.conf ${OUTPUT_DIR_PATH}/nginx-nginx.conf.${server}
  rsync -az ${server}:/etc/nginx/sites-available/isucon.conf ${OUTPUT_DIR_PATH}/nginx-sites-available-isucon.conf.${server}
  rsync -az ${server}:/var/log/nginx/access.log ${OUTPUT_DIR_PATH}/nginx-access.log.${server}
  echo "${server}: Downloaded nginx analysis files👍️"
done < ${INPUT_FILE}

#
# MySQL
# - /etc/mysql/mysql.conf.d/mysqld.cnf
# - /var/log/mysql/mysql-slow.log
echo "-------[ ⬇️Download mysql files for analysis ]"
while read server; do
  rsync -az ${server}:/etc/mysql/mysql.conf.d/mysqld.cnf ${OUTPUT_DIR_PATH}/mysql-mysqld.cnf.${server}
  rsync -az ${server}:/var/log/mysql/mysql-slow.log ${OUTPUT_DIR_PATH}/mysql-mysql-slow.log.${server}
  echo "${server}: Downloaded mysql analysis files👍️"
done < ${INPUT_FILE}

#
# シンボリックリンク
#
readonly LATEST_DIR_PATH="tmp/analysis/latest"
rm -f ${LATEST_DIR_PATH}
ln -sf $(realpath ${OUTPUT_DIR_PATH}) ${LATEST_DIR_PATH}

echo "Downloaded analysis files🙌: ${OUTPUT_DIR_PATH}"
