# ローカル開発環境セットアップ（with Docker）

開発効率（テスト（rspec）の実行スピード、デバッグの簡易性等）を重視して、rails はローカル環境、それ以外は Docker 化したものを使う前提としています。\
これに伴い、docker-compose.yml 内の rails をコメントアウトしている。

以下、Docker の参考バージョン。

```sh
$ docker -v
Docker version 20.10.23, build 7155243

$ docker-compose -v
Docker Compose version v2.15.1
```

## 環境変数

1. `.env`ファイルを用意

    ```sh
    cp .env.sample .env
    ```

2. `.env`ファイルを編集

> 以下、UID, GID は未参照（rails で使う環境変数のため）。また、minio に関する環境変数も設定不要。

    |環境変数名|説明|
    |---|---|
    |UID|コンテナ内部のRailsアプリケーションのファイルを所有するユーザーのUID<br>開発ではホストのディレクトリをマウントするが所有者がホストのユーザーになる場合があるのでホストのUIDを指定する<br>(ホストOSにログインしていユーザーのUIDは`id -u`で取得できます)|
    |GID|必須か不明<br>当面はホストOS`id -g`の出力結果を設定してください|

## 操作

プロジェクトルートで以下コマンドを実行。

```sh
# イメージを作成
$ docker-compose build

# イメージを作成（without cache)
$ docker-compose build --no-cache

# コンテナを起動（フォアグラウンド実行）
$ docker-compose up

# コンテナを起動（バックグラウンド実行）
$ docker-compose up -d

# db:migrate実行
$ bin/rails db:migrate

# db:seed実行
$ bin/rails db:seed

# コンテナ削除
$ docker-compose down

# コンテナ削除（データベース・ボリューム含む）
$ docker-compose down -v
```

テストDB構築

```sh
$ bin/rails db:create RAILS_ENV=test

$ bin/rails db:migrate RAILS_ENV=test
```

以下は、rails も Docker 化している状態のコマンド群のため、現在は参照不要。

```sh
# イメージを作成
$ docker-compose build

# イメージを作成（without cache)
$ docker-compose build --no-cache

# db:migrate実行
$ docker-compose run --rm web rails db:migrate

# db:seed実行
$ docker-compose run --rm web rails db:seed

# コンテナを起動（フォアグラウンド実行）
$ docker-compose up

# コンテナを起動（バックグラウンド実行）
$ docker-compose up -d

# rails consoleに接続
$ docker-compose run --rm web rails console

# web containerに接続
$ docker-compose exec web /bin/sh

# コンテナ削除
$ docker-compose down

# コンテナ削除（データベース・ボリューム含む）
$ docker-compose down -v
```

## rspec実行

以下は、rails も Docker 化している状態のコマンド群のため、通常開発時は参照不要。\
`bundle exec rspec` や `bin/rspec` を使って下さい。

> 毎回 `docker-compose run` するのは処理が遅いので、要再考。ひとまずローカルで実行するのが処理が速いかも。

```sh
# db:create実行
$ docker-compose run --rm web rails db:create RAILS_ENV=test

# db:migrate実行
$ docker-compose run --rm web rails db:migrate RAILS_ENV=test

# rspec実行
$ docker-compose run --rm -e RAILS_ENV=test web bundle exec rspec
```

## 新しい gem や npm module を追加した場合の対応

以下の手順に沿って、docker 上の rails で動作確認を行う。\
`Dockerfile` への変更が必要になる場合があることに留意する（この手順は、主にこれを確認するためのもの）。\
変更が必要な場合は、PR に含める。

1. `docker-compose.yml` の `web` のコメントアウトを外す
1. `.env` で必要な環境変数（`web` に関するもの）を有効化する
1. `docker-compose build --no-cache` を実行
1. `docker-compose run --rm -e RAILS_ENV=test web bundle exec rspec` を実行
1. rspec 実行以外に変更に伴う動作確認が必要な場合は行う

## Minioを使う

[コンソール](http://localhost:9000) にアクセスするとブラウザから minio を使うことができます。
署名付きURLなど、Railsを経由しないでs3にアクセスする場合は、hostsを変更するなどしてdocker内と同じドメインでつながるようにしてください。

```sh
# 例
$ cat /etc/hosts
127.0.0.1 localhost
...

127.0.0.1 minio

```

## トラブルシューティング

### build がうまくできない

Linux: `.env`ファイルの`UID`と`GID`が使用している OS のものと正しいか確認してください。
Mac: Docker内の既存のidと衝突している場合は、別の値を使用してください (1000など)

エラー例:

```sh
failed to solve: executor failed running [/bin/sh -c set -x &&   deluser node &&   addgroup -g ${GID} -S ${APP_USER} &&   adduser -g '' -S -D -u ${UID} ${APP_USER} &&   mkdir -p ${WORKDIR} &&   chown -R ${APP_USER}:${APP_USER} ${WORKDIR}]: exit code: 1
```

### `A server is already running. Check /app/tmp/pids/server.pid.`

エラー例:

    web_1   | => Booting Puma
    web_1   | => Rails 7.0.5 application starting in development
    web_1   | => Run `bin/rails server --help` for more startup options
    web_1   | A server is already running. Check /app/tmp/pids/server.pid.
    web_1   | Exiting
    web_1 exited with code 1

`server.pid`ファイルがある場合は一度削除してから再度`docker-compose up`してみてください。

注意: Ctrl+C を連打する(rails サーバーを kill する)と server.pid が残ってしまうようです。

参考: [Can't stop rails server](https://stackoverflow.com/questions/15088163/cant-stop-rails-server)
