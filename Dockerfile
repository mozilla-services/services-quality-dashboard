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
  apt-get install -y ruby2.0 && \
  apt-get install -y ruby2.0-dev && \
  apt-get install -y git nodejs-legacy npm && \
  apt-get install -y software-properties-common curl

# Force Ruby 2.0 to default
RUN ln -fs /usr/bin/ruby2.0 /usr/bin/ruby
RUN ln -fs /usr/bin/gem2.0 /usr/bin/gem

# Install Ruby Gems
RUN \
  gem install dashing --no-ri --no-rdoc && \
  gem install god --no-ri --no-rdoc && \
  gem install bundler --no-ri --no-rdoc

ADD . /services-quality-dashboard

WORKDIR /services-quality-dashboard

RUN bundle install

EXPOSE 80

CMD ["god", "-c", "monitor.god", "-D"]
