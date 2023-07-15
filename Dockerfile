FROM ruby:3.2.2-alpine

ARG UID=1000
ARG GID=1000
ARG RAILS_ENV=production

ENV APP_USER=app
ENV WORKDIR=/app
ENV RAILS_LOG_TO_STDOUT=true

# gcompatが無いとrails起動時にnokogiriがエラーになる
# https://github.com/sparklemotion/nokogiri/issues/2416
# https://nokogiri.org/tutorials/installing_nokogiri.html#linux-musl-error-loading-shared-library

RUN apk add --no-cache --update build-base \
  linux-headers \
  postgresql-dev \
  tzdata \
  busybox-suid \
  shared-mime-info \
  gcompat

RUN set -x && \
  addgroup -g ${GID} -S ${APP_USER} && \
  adduser -g '' -S -D -u ${UID} ${APP_USER} && \
  mkdir -p ${WORKDIR} && \
  chown -R ${APP_USER}:${APP_USER} ${WORKDIR}

WORKDIR ${WORKDIR}
USER ${APP_USER}

COPY --chown=${APP_USER}:${APP_USER} Gemfile Gemfile.lock ./

RUN bundle install
# debaseを含めてbundle installすると落ちるので、分けてインストールしている。
#
# また、Ruby3.x はv0.2.4だと動かないので更に新しいものを使っている
#
# 経緯:
# IntelliJ でデバッグするにはdebaseが必要
#   -> debaseは Ruby3.x に対する対応が不完全
#   -> Gemfileにdebaseを入れるとビルドに失敗する
#   -> bundle installした後に直接gem installすると入る (理由は不明。bundle install後にGemfileにdebaseを追加してもう一度bundle installしても入る)
#   -> IntelliJはコンテナ内でパスが通っていれば動くので、Gemfileに書く必要はない
#   -> Dockerfileに直書きする
#
# c.f.)
#   https://pleiades.io/help/ruby/debugging-code.html
#   > デバッグには... debase および ruby-debug-ide gems がインストールされている必要があります
#
#   debaseのRuby3.x対応に関連するissue
#   * https://github.com/ruby-debug/debase/issues/94
#   * https://github.com/ruby-debug/debase/issues/95
RUN gem install debase -v 0.2.5.beta2
RUN gem install ruby-debug-ide

COPY --chown=${APP_USER}:${APP_USER} . ./

CMD [ "rails", "s", "-b", "0.0.0.0" ]

EXPOSE 3000
