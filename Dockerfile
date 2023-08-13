FROM --platform=linux/amd64 ruby:3.2.0 AS dev

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  bison \
  cmake \
  curl \
  flex \
  fonts-lyx \
  fonts-noto-cjk \
  libcairo2-dev \
  libffi-dev \
  libgdk-pixbuf2.0-dev \
  libpango1.0-dev \
  libxml2-dev \
  locales

RUN curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb -o /tmp/wkhtmltox.deb && \
  apt-get install -y /tmp/wkhtmltox.deb && \
  rm /tmp/wkhtmltox.deb

RUN gem install bundler

RUN sed -i 's/^# *\(zh_CN.UTF-8\)/\1/' /etc/locale.gen && locale-gen
ENV LANG=zh_CN.UTF-8

WORKDIR /asciibook

COPY asciibook.gemspec /asciibook/asciibook.gemspec
COPY Gemfile /asciibook/Gemfile
COPY lib/asciibook/version.rb /asciibook/lib/asciibook/version.rb
RUN bundle install

FROM dev AS release

COPY . /asciibook
RUN rake install && rm -r /asciibook/*
