FROM ruby:3.2.1-alpine

ENV LANG C.UTF-8

ARG APP_ROOT=/workspace
ARG BUILD_PACKAGES="build-base curl-dev ruby-dev git"
ARG DEV_PACKAGES="yaml-dev zlib-dev mysql-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata ruby-json yaml"

RUN apk add --update \
  $BUILD_PACKAGES \
  $DEV_PACKAGES \
  $RUBY_PACKAGES

ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

ENV GEM_HOME /$APP_ROOT/vendor/bundle
ENV BUNDLE_PATH /$APP_ROOT/vendor/bundle
ENV BUNDLE_BIN /$APP_ROOT/vendor/bundle/bin
ENV PATH $BUNDLE_BIN:$BUNDLE_PATH/gems/bin:$PATH

COPY ./docker-entrypoint.sh /
COPY ./docker-entrypoint-worker.sh /
RUN chmod +x /docker-entrypoint.sh /docker-entrypoint-worker.sh
COPY ./wait-for-it.sh /
RUN chmod +x /wait-for-it.sh

EXPOSE 3000
