.PHONY: build-cfn
build-cfn: ## CFnファイルをbuild
	@([ -e tmp/cloudformation.yml ] && echo 'build済みです') || (echo 'buildします' && bash scripts/build-cfn.sh)
	@diff -ur cloudformation.template.yml tmp/cloudformation.yml | delta

.PHONY: create-sshconfig-for-isucon
create-sshconfig-for-isucon: ## ~/.ssh/config-for-isucon.d/config 作成
	@bash scripts/create-sshconfig-for-isucon.sh

.PHONY: check-ssh
check-ssh: tmp/servers ## CFnでEC2を設置して、sshできるか確認する
	@cat tmp/servers | xargs -I{} bash -c 'echo "----[ {} ]" && ssh {} "ls"'

.PHONY: clean
clean: ## 掃除
	@rm -rf tmp/*

.PHONY: initialize-before
initialize-before: ## beforeシリーズを初期化
	@bash scripts/initialize-before.sh

.PHONY: reset
reset: ## app,commonを削除し、beforeシリーズからもってくる
	@rm -rf app common
	@cp -rf before-app app
	@cp -rf before-common common

.PHONY: port-forward-for-isu-1
port-forward-for-isu-1: ## 別shellで行う:Remote(isu-1)の:3100への接続をLocal:3100へポートフォワーディング(Rオプション)
	grep 'isu-1' tmp/app-servers &> /dev/null && ssh isu-1 -R 3100:localhost:3100 -N

################################################################################
# o11y
################################################################################
.PHONY: build-prometheus-yml
build-prometheus-yml: ## prometheus.ymlをビルド
	@bash scripts/build-prometheus-yml.sh

################################################################################
# 各Hostで入れておきたいツール群
################################################################################
.PHONY: setup-tools
setup-tools: tmp/servers ## 各Hostでツール群をインストール
	@cat tmp/servers | xargs -I{} ssh {} "sudo apt-get update && sudo apt-get install -y psmisc tmux tree make jq neovim git gv graphviz prometheus-node-exporter"
	@cat tmp/app-servers | xargs -I{} ssh {} "sudo apt-get update && sudo apt-get install -y prometheus-mysqld-exporter prometheus-nginx-exporter"

.PHONY: install-fluent-bit
install-fluent-bit: ## fluent-bitをインストール
	@bash scripts/install-fluent-bit.sh

################################################################################
# MySQL
################################################################################
.PHONY: show-mysql-info
show-mysql-info: ## MySQLの情報を表示
	@bash scripts/show-mysql-info.sh

################################################################################
# private-isu
################################################################################
.PHONY: enable-isu-go
enable-isu-go: ## isu-rubyを止めて、isu-goを有効化
	@cat tmp/app-servers | xargs -I{} bash -c 'echo "----[ {} ]" && ssh {} "sudo systemctl disable --now isu-ruby && sudo systemctl enable --now isu-go"'

.PHONY: deploy
deploy: ## デプロイ
	@bash scripts/deploy.sh

.PHONY: bench
bench: ## benchmarkerを実行
	@bash scripts/clean-logs.sh
	ssh isu-bench "private_isu.git/benchmarker/bin/benchmarker -u private_isu.git/benchmarker/userdata -t http://192.168.1.10/"

################################################################################
# kaizen
################################################################################
.PHONY: scores
scores: ## socre一覧
	@git log --oneline | grep score | head -n10

.PHONY: kaizen-index
kaizen-index: ## MySQLのindexによるkaizen
	@bash common/kaizen-index.sh

.PHONY: onetime-scripts
onetime-scripts: ## onetime scriptを同期、実行
	@bash scripts/onetime-scripts.sh

.PHONY: download-files-for-analysis
download-files-for-analysis: ## 分析用ファイル群をダウンロード
	@bash scripts/download-files-for-analysis.sh

.PHONY: analyze
analyze: ## ダウンロードしたファイルを分析
	@bash scripts/analyze.sh

.PHONY: dl-and-analyze
dl-and-analyze: ## 分析用ファイル群をダウンロードして、分析
	@make download-files-for-analysis && echo '' && make analyze

.PHONY: cat-alp-result
cat-alp-result: ## alp結果を表示
	@cat tmp/analysis/latest/analyzed-alp-nginx-access.log.*

.PHONY: cat-pt-query-digest-result
cat-pt-query-digest-result: ## pt-query-digest結果を表示
	@cat tmp/analysis/latest/analyzed-pt-query-digest-slow.log.*

################################################################################
# Utility-Command help
################################################################################
.DEFAULT_GOAL := help

################################################################################
# マクロ
################################################################################
# Makefileの中身を抽出してhelpとして1行で出す
# $(1): Makefile名
# 使い方例: $(call help,{included-makefile})
define help
  grep -E '^[\.a-zA-Z0-9_-]+:.*?## .*$$' $(1) \
  | grep --invert-match "## non-help" \
  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
endef

################################################################################
# タスク
################################################################################
.PHONY: help
help: ## Make タスク一覧
	@echo '######################################################################'
	@echo '# Makeタスク一覧'
	@echo '# $$ make XXX'
	@echo '# or'
	@echo '# $$ make XXX --dry-run'
	@echo '######################################################################'
	@echo $(MAKEFILE_LIST) \
	| tr ' ' '\n' \
	| xargs -I {included-makefile} $(call help,{included-makefile})
