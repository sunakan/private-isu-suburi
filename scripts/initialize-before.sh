#!/bin/bash -eux

#
# limits.conf
#
mkdir -p before-common/etc/security/
test -f before-common/etc/security/limits.conf || rsync -az isu-1:/etc/security/limits.conf before-common/etc/security/limits.conf

#
# env.sh
#
mkdir -p before-common/
test -f before-common/env.sh || rsync -az isu-1:/home/isucon/env.sh before-common/env.sh

#
# Nginx
#
mkdir -p before-common/etc/nginx/sites-available
test -f before-common/etc/nginx/nginx.conf || rsync -az isu-1:/etc/nginx/nginx.conf before-common/etc/nginx/nginx.conf
test -f before-common/etc/nginx/sites-available/isucon.conf || rsync -az isu-1:/etc/nginx/sites-available/isucon.conf before-common/etc/nginx/sites-available/isucon.conf

#
# MySQL
#
mkdir -p before-common/etc/mysql/mysql.conf.d
test -f before-common/etc/mysql/mysql.conf.d/mysqld.cnf || rsync -az isu-1:/etc/mysql/mysql.conf.d/mysqld.cnf before-common/etc/mysql/mysql.conf.d/mysqld.cnf

#
# App
#
mkdir -p before-app/golang
test -f before-app/golang/go.mod || rsync -az --exclude='app' isu-1:/home/isucon/private_isu/webapp/golang/ before-app/golang/

#
# Systemd unit
#
mkdir -p before-common/etc/systemd/system
test -f before-common/etc/systemd/system/isu-go.service || rsync -az isu-1:/etc/systemd/system/isu-go.service before-common/etc/systemd/system/isu-go.service

#
# tree
#
tree before-common/
tree before-app/
