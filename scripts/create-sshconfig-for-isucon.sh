#!/bin/bash -eux

#
# ssh configを作成
#
mkdir -p ~/.ssh/config-for-isucon.d
aws ec2 describe-instances --filters 'Name=instance-state-name,Values=running' --output json --query 'Reservations[].Instances[]' \
  | jq -rc '.[] | {ip: .NetworkInterfaces[0].Association.PublicIp, name: .Tags[] | select(.Key == "Name") | .Value}' \
  | jq -src '. | sort_by(.name)[] | ["isu-\(.name | split("-")[1])", .ip] | @csv' \
  | sed 's/"//g' \
  > tmp/hosts.csv
cat tmp/hosts.csv \
  | awk -F, '{print "Host "$1"\n  HostName "$2"\n  User isucon\n  IdentityFile ~/.ssh/id_rsa\n  StrictHostKeyChecking no\n  UserKnownHostsFile /dev/null"}' \
  > ~/.ssh/config-for-isucon.d/config
chmod 644 ~/.ssh/config-for-isucon.d/config
echo '~/.ssh/config-for-isucon.d/configを作成しました'
echo '----------------------------------------'
cat ~/.ssh/config-for-isucon.d/config
echo '----------------------------------------'
echo '~/.ssh/configの先頭に以下を記述してください'
echo 'Include ~/.ssh/config-for-isucon.d/config'

#
# サーバー群をリスト化
#
cat tmp/hosts.csv | cut -d',' -f1 > tmp/servers
cat tmp/servers | grep -v 'bench' > tmp/app-servers
