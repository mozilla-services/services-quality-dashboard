#
# Services Quality Dashboard Dockerfile
#
# https://github.com/mozilla-services/services-quality-dashboard
#

FROM ubuntu:14.04

# Install basic dependencies
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common

# Install project specific dependencies
RUN \
  apt-get install -y ruby ruby-dev git nodejs-legacy npm && \
  gem install dashing --no-ri --no-rdoc && \
  gem install god --no-ri --no-rdoc && \
  gem install bundler --no-ri --no-rdoc

ADD . /services-quality-dashboard

WORKDIR /services-quality-dashboard

RUN bundle install

EXPOSE 80

CMD ["god", "-c", "monitor.god", "-D"]
