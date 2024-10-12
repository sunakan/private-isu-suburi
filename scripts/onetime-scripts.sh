#!/bin/bash -eux

#
# onetime scriptをrsyncして、実行
#
# INPUT:
# - tmp/app-servers
# OUTPUT:
# - script内容による
#

readonly INPUT_FILE="tmp/app-servers"

#
# rsync
#
while read server; do
  rsync -az common/scripts/ ${server}:~/scripts/
  ssh $server 'export PATH=$PATH:/home/isucon/.local/go/bin && cd /home/isucon/scripts/write-images/ && go run main'
done < ${INPUT_FILE}

#onetime-scripts: ## onetime scriptを同期、実行
#@cat tmp/app-servers | xargs -I{} rsync -az common/scripts/ {}:~/scripts/
#@cat tmp/app-servers | xargs -I{} ssh {} "bash ~/scripts/onetime-scripts.sh"
# cat tmp/app-servers | xargs -I{} ssh {} 'export PATH=$PATH:/home/isucon/.local/go/bin && cd /home/isucon/private_isu/webapp/golang/ && make app && sudo systemctl restart isu-go'
