#!/bin/bash -eux

# INPUT
# tmp/hosts.csv
# isu-1,192.168.0.1
# isu-2,192.168.0.2
#
export ENV_MONITORING_TARGETS=$(cat tmp/hosts.csv | grep -v 'bench' | cut -d',' -f2 | xargs -I{} echo '"{}:9100"' | tr '\n' ',' | sed 's/,$//' | awk '{print "["$0"]"}')
envsubst '$ENV_MONITORING_TARGETS' < plg-stack/prometheus/prometheus.template.yml > tmp/prometheus.yml

diff -u plg-stack/prometheus/prometheus.template.yml tmp/prometheus.yml | delta
