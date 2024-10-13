#!/bin/bash -eux

#
# limits.conf
#
echo '-------[ 🚀Deploy limits🚀 ]'
cat tmp/servers | xargs  -I{} rsync -az --rsync-path="sudo rsync" ./common/etc/security/limits.conf {}:/etc/security/limits.conf

#
# env.sh
#
echo ''
echo '-------[ 🚀Deploy env.sh🚀 ]'
cat tmp/app-servers | xargs -I{} rsync -az ./common/env.sh {}:/home/isucon/env.sh

#
# Nginx
#
echo ''
echo '-------[ 🚀Deploy Nginx🚀 ]'
cat tmp/app-servers | xargs -I{} rsync -az --rsync-path="sudo rsync" ./common/etc/nginx/nginx.conf {}:/etc/nginx/nginx.conf
cat tmp/app-servers | xargs -I{} rsync -az --rsync-path="sudo rsync" ./common/etc/nginx/sites-available/isucon.conf {}:/etc/nginx/sites-available/isucon.conf
cat tmp/app-servers | xargs -I{} ssh {} 'sudo nginx -t && sudo systemctl reload nginx'
cat tmp/app-servers | xargs -I{} ssh {} 'sudo chmod +rx /var/log/nginx/ && sudo chmod +r /var/log/nginx/*log'

#
# MySQL
#
echo ''
echo '-------[ 🚀Deploy MySQL🚀 ]'
cat tmp/app-servers | xargs -I{} ssh {} "sudo mysql -e \"create user if not exists 'isucon'@'%' identified by 'isucon'\""
cat tmp/app-servers | xargs -I{} ssh {} "sudo mysql -e \"grant all privileges on isuconp.* to 'isucon'@'%';\""
cat tmp/app-servers | xargs -I{} rsync -az --rsync-path="sudo rsync" ./common/etc/mysql/mysql.conf.d/mysqld.cnf {}:/etc/mysql/mysql.conf.d/mysqld.cnf
cat tmp/app-servers | xargs -I{} ssh {} 'sudo systemctl restart mysql'
cat tmp/app-servers | xargs -I{} ssh {} 'sudo chmod +rx /var/log/mysql/ && sudo chmod +r /var/log/mysql/*log'

#
# App
#
echo ''
echo '-------[ 🚀Deploy App🚀 ]'
cat tmp/app-servers | xargs -I{} rsync -az ./app/golang/ {}:/home/isucon/private_isu/webapp/golang/
cat tmp/app-servers | xargs -I{} ssh {} 'export PATH=$PATH:/home/isucon/.local/go/bin && cd /home/isucon/private_isu/webapp/golang/ && make app && sudo systemctl restart isu-go'
