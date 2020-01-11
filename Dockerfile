FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  git \
  fonts-noto-cjk \
  ruby \
  ruby-dev

RUN curl -L https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb -o wkhtmltox_0.12.5-1.bionic_amd64.deb && \
  apt-get install -y ./wkhtmltox_0.12.5-1.bionic_amd64.deb && \
  rm wkhtmltox_0.12.5-1.bionic_amd64.deb

RUN gem install bundler -v 2.0.2

WORKDIR /asciibook

COPY . /asciibook

RUN bundler install
