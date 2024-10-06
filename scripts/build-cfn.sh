#!/bin/bash -eux

# Check using commands
required_commands=("jq" "rq" "envsubst" "curl")
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


#
# cloudformation.template.ymlを修正したCFnファイルをビルド
#
# INPUT1: cloudformation.template.yml
# OUTPUT: tmp/cloudformation.yml
#
export ENV_MY_IP="$(curl -s https://ipinfo.io/ip)/32"
export ENV_GITHUB_USERNAME="${ENV_GITHUB_USERNAME}"
envsubst '$ENV_MY_IP $ENV_GITHUB_USERNAME' < cloudformation.template.yml > tmp/cloudformation.yml
