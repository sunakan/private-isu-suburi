#!/usr/bin/env bash
set -eu
# -e: エラーが発生した時点でスクリプトを終了します。
# -u: 未定義の変数を使用した場合にエラーを発生させます。

#
# URLとダウンロード先を設定
#
readonly URL="https://packages.fluentbit.io/fluentbit.key"
readonly EXPECTED_CHECKSUM="df248e2d7103ca62cb683c20a077198d0fb0a7f79dbf53a604af0317de3b4711"
readonly DISTRO_RELEASE=$(cat tmp/app-servers | head -n 1 | xargs -I{} ssh {} "lsb_release -cs")

#
# GPGキーをダウンロード
#
# -f (--fail): サーバーエラーの場合に静かに失敗します。エラーメッセージを表示せず、エラーステータスを返します。
# -s (--silent): プログレスメーターやエラーメッセージを表示しません。静かに実行します。
# -S (--show-error): -sオプションと組み合わせて使用します。エラーが発生した場合にエラーメッセージを表示します。
# -L (--location): リダイレクトに従います。HTTPリダイレクトがある場合、自動的に新しいURLにリクエストを送ります。
#
if ! curl -fsSL "$URL" -o ./tmp/fluentbit-keyring.asc; then
  echo "ダウンロードに失敗しました。"
  exit 1
fi
readonly ACTUAL_CHECKSUM=$(sha256sum ./tmp/fluentbit-keyring.asc | cut -d' ' -f1)
if [ "$ACTUAL_CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
  echo "チェックサムが一致しません。ファイルが破損している可能性があります。"
  echo "消してください: ./tmp/fluentbit-keyring.asc"
  exit 1
fi

#
# sources.listファイルを作成
#
echo "deb [signed-by=/etc/apt/keyrings/fluentbit-keyring.asc] https://packages.fluentbit.io/ubuntu/$DISTRO_RELEASE $DISTRO_RELEASE main" > tmp/fluentbit.list

#
# ディレクトリが存在しない場合は作成
#
cat tmp/app-servers | xargs -I{} ssh {} "sudo mkdir -p /etc/apt/keyrings/"

#
# ファイルを転送
#
cat tmp/app-servers | xargs -I{} rsync -az --rsync-path="sudo rsync" ./tmp/fluentbit-keyring.asc {}:/etc/apt/keyrings/fluentbit-keyring.asc
cat tmp/app-servers | xargs -I{} rsync -az --rsync-path="sudo rsync" ./tmp/fluentbit.list {}:/etc/apt/sources.list.d/fluentbit.list

#
# パッケージリストをクリーンアップ、パッケージリストの更新、Fluent Bitのインストール
#
cat tmp/app-servers | xargs -I{} ssh {} "sudo apt-get autoclean && sudo apt-get update && sudo apt-get install -y fluent-bit"

# バージョン確認
# /opt/fluent-bit/bin/fluent-bit -V
# Fluent Bit v3.1.9
# Git commit:
