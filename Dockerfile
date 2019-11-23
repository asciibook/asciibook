FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  git \
  ruby \
  ruby-dev

RUN gem install bundler -v 2.0.2

WORKDIR /asciibook
