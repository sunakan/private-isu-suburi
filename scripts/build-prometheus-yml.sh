#!/bin/bash -eux

# INPUT
# tmp/hosts.csv
# isu-1,192.168.0.1
# isu-2,192.168.0.2
#

#
# Node Exporterのポート番号: 9100
# MySQL Exporterのポート番号: 9104
# Nginx Exporterのポート番号: 9113
#
export ENV_NODE_EXPORTER_TARGETS=$(cat tmp/hosts.csv | grep -v 'bench' | cut -d',' -f2 | xargs -I{} echo '"{}:9100"' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')
export ENV_MYSQL_EXPORTER_TARGETS=$(cat tmp/hosts.csv | grep -v 'bench' | cut -d',' -f2 | xargs -I{} echo '"{}:9104"' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')
export ENV_NGINX_EXPORTER_TARGETS=$(cat tmp/hosts.csv | grep -v 'bench' | cut -d',' -f2 | xargs -I{} echo '"{}:9113"' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')
envsubst '$ENV_NODE_EXPORTER_TARGETS $ENV_MYSQL_EXPORTER_TARGETS $ENV_NGINX_EXPORTER_TARGETS' < plg-stack/prometheus/prometheus.template.yml > tmp/prometheus.yml

diff -u plg-stack/prometheus/prometheus.template.yml tmp/prometheus.yml | delta
