FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  git \
  fonts-noto-cjk \
  ruby \
  ruby-dev \
  zlib1g-dev

RUN curl -L https://builds.wkhtmltopdf.org/0.12.6-dev/wkhtmltox_0.12.6-0.20180618.3.dev.e6d6f54.bionic_amd64.deb -o wkhtmltox.deb && \
  apt-get install -y ./wkhtmltox.deb && \
  rm wkhtmltox.deb

RUN gem install bundler -v 2.0.2

WORKDIR /asciibook

COPY . /asciibook

RUN bundler install
