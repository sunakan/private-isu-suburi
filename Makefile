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

################################################################################
# 各Hostで入れておきたいツール群
################################################################################
.PHONY: setup-tools
setup-tools: tmp/servers ## 各Hostでツール群をインストール
	@cat tmp/servers | xargs -I{} ssh {} "sudo apt-get update && sudo apt-get install -y psmisc tmux tree make jq neovim git graphviz prometheus-node-exporter"

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
	ssh isu-bench "private_isu.git/benchmarker/bin/benchmarker -u private_isu.git/benchmarker/userdata -t http://192.168.1.10/"

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
