# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DDCLIENT_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="saarg"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    gcc \
    make \
    wget && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    bind-tools \
    inotify-tools \
    perl \
    perl-digest-sha1 \
    perl-io-socket-inet6 \
    perl-io-socket-ssl \
    perl-json

RUN echo "***** install perl modules ****" && \
  curl -L http://cpanmin.us | perl - App::cpanminus && \
  cpanm \
    Data::Validate::IP \
    JSON::Any

RUN echo "**** install ddclient ****" && \
  curl -o /tmp/ddclient.tar.gz -L "https://api.github.com/repos/ddclient/ddclient/tarball/" && \
  tar xf /tmp/ddclient.tar.gz -C /tmp/ddclient --strip-components=1 && \
  cp /tmp/ddclient/ddclient.in /usr/bin/ddclient.in && \
  ln -s /usr/bin/ddclient.in /usr/bin/ddclient && \
  mkdir -p /etc/ddclient/ && \
  cp /tmp/ddclient/sample-get-ip-from-fritzbox /etc/ddclient/get-ip-from-fritzbox && \

RUN echo "**** cleanup ****" && \
  apk del --purge build-dependencies && \
  rm -rf \
    /config/.cpanm \
    /root/.cpanm \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config
