# private-isuの素振り

- https://github.com/catatsuy/private-isu

## Golangにswitchして、スコアの初期値

```json
{"pass":true,"score":2298,"success":2208,"fail":0,"messages":[]}
```

2回目

```json
{"pass":true,"score":2339,"success":2251,"fail":0,"messages":[]}
```

## セットアップ

```shell
make clean
make build-cfn
# tmp/cloudformation.ymlでスタック作成

make create-sshconfig-for-isucon
make check-ssh
make enable-isu-go
make bench

# 継続的改善
make deploy
make bench
make dl-and-analyze
make cat-alp-result
make cat-pt-query-digest-result
```
