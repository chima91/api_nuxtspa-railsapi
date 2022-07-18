# FROM ベースイメージ:タグ
FROM ruby:2.7.6-alpine

# Dockerfileをビルドする際に指定可能なビルド引数を定義(Dockerfile内で使用する変数を定義)
ARG WORKDIR
ARG RUNTIME_PACKAGES="nodejs tzdata postgresql-dev postgresql git"
ARG DEV_PACKAGES="build-base curl-dev"

# 環境変数を定義(Dockerfile, コンテナから参照可能)
ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# Dockerfile内で指定した命令(RUN, COPY, ADD, ENTORYPOINT, CMD)を実行する作業ディレクトリを定義
WORKDIR ${HOME}

# ホストのファイルをコンテナにコピー
# ホスト: Dockerfileがあるディレクトリ配下を指定
# コンテナ: 絶対パス or 相対パス
COPY Gemfile* ./

# ベースイメージに対してコマンドを実行
# apk: Alpine Linuxのコマンド
RUN apk update && \
    apk upgrade && \
    # --no-cache = パッケージをキャッシュしない = DockerImageを軽量化
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    # --virtual 任意の名前 = 仮想パッケージ
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    # -j4(jobs=4) = Gemインストールの高速化
    bundle install -j4 && \
    apk del build-dependencies

COPY . ./

# 生成されたコンテナ内で実行したいコマンドを定義
# -b(bind) = 指定したIPアドレスにプロセスを紐付ける
# CMD ["rails", "server", "-b", "0.0.0.0"]