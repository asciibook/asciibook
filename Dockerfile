FROM ubuntu:18.04 AS base

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
  bison \
  build-essential \
  cmake \
  curl \
  flex \
  fonts-lyx \
  libcairo2-dev \
  libffi-dev \
  libgdk-pixbuf2.0-dev \
  libpango1.0-dev \
  libxml2-dev \
  ruby \
  ruby-dev \
  zlib1g-dev

RUN curl -L https://builds.wkhtmltopdf.org/0.12.6-dev/wkhtmltox_0.12.6-0.20180618.3.dev.e6d6f54.bionic_amd64.deb -o /tmp/wkhtmltox.deb && \
  apt-get install -y /tmp/wkhtmltox.deb

RUN curl http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz -o /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz && \
  tar -xzf /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz -C /tmp && \
  mv /tmp/kindlegen /usr/bin/ && \
  rm /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz

RUN gem install bundler -v 2.0.2

WORKDIR /asciibook

FROM base AS dev

COPY asciibook.gemspec /asciibook/asciibook.gemspec
COPY Gemfile /asciibook/Gemfile
COPY lib/asciibook/version.rb /asciibook/lib/asciibook/version.rb
RUN bundle install

FROM base AS builder

COPY . /asciibook
RUN gem build asciibook.gemspec

FROM ubuntu:18.04 AS release

RUN apt-get update && apt-get install -y --no-install-recommends \
  bison \
  flex \
  fonts-lyx \
  libcairo2 \
  libffi6 \
  libgdk-pixbuf2.0 \
  libpango1.0 \
  libxml2 \
  ruby

COPY --from=base /tmp/wkhtmltox.deb /tmp/wkhtmltox.deb
RUN apt-get install -y /tmp/wkhtmltox.deb

COPY --from=base /usr/bin/kindlegen /usr/bin/kindlegen

COPY --from=dev /var/lib/gems /var/lib/gems

COPY --from=builder /asciibook/asciibook-*.gem /tmp
RUN gem install /tmp/asciibook-*.gem

FROM release AS cjk

RUN apt-get update && apt-get install -y --no-install-recommends \
  fonts-noto-cjk \
  locales

ARG locale=zh_CN.UTF-8

RUN locale-gen $locale

ENV LANG=$locale
