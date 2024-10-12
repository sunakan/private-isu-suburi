#!/bin/bash -eux

#
# ダウンロードしたファイル群を分析
#
# INPUT:
# - tmp/app-servers
# OUTPUT:
# - tmp/analysis/latest/alp-nginx-access.log.*
# - tmp/analysis/latest/pt-query-digest-slow.log.*
#
readonly INPUT_FILE="tmp/app-servers"
readonly LATEST_DIR_PATH="tmp/analysis/latest"

#
# コマンドの有無チェック
#
required_commands=("alp" "pt-query-digest")
missing_commands=()
for cmd in "${required_commands[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    missing_commands+=("$cmd")
  fi
done
if [ ${#missing_commands[@]} -ne 0 ]; then
  echo "以下のコマンドが見つかりません。インストールしてください:"
  for cmd in "${missing_commands[@]}"; do
    echo "- $cmd"
  done
  exit 1
fi

echo "-------[ ANALYZED ]"
#
# Nginxのアクセスログを分析
#
while read server; do
  OUTPUT_FILE="${LATEST_DIR_PATH}/analyzed-alp-nginx-access.log.${server}"
  echo ${server} > "${OUTPUT_FILE}"
  echo 'P90: レスポンスの90%がこの数値以下のレスポンスタイム' >> "${OUTPUT_FILE}"
  echo 'STDDEV: 標準偏差(Standard Deviation)、値が大きいほどばらつきが大きい(=不安定)' >> "${OUTPUT_FILE}"
  alp ltsv --sort=sum --reverse --file ${LATEST_DIR_PATH}/nginx-access.log.${server} \
    -m '/image/\d+.(jpg|png|gif),/posts/\d+,/@\w+' \
    >> "${OUTPUT_FILE}"
  echo "less ${OUTPUT_FILE}"
done < ${INPUT_FILE}


#
# MySQLのスロークエリログを分析
#
while read server; do
  OUTPUT_FILE="${LATEST_DIR_PATH}/analyzed-pt-query-digest-slow.log.${server}"
  pt-query-digest --limit 15 ${LATEST_DIR_PATH}/mysql-mysql-slow.log.${server} > "${OUTPUT_FILE}"
  echo "less ${OUTPUT_FILE}"
done < ${INPUT_FILE}
