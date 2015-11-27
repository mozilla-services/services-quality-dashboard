# Build it yourself

bundle install (there may be additional prerequisites depending on your system,  gem install bundler, etc.)

dashing start

Visit localhost:3030 to view

# Using Docker

Build the image and run it:
$ docker build -t dashboard .
$ docker run -t -i -d -P -p 80:80 dashboard

If you're running docker directly on your host linux then you should see the dashboard on localhost, if you're on windows or osx machine and running docker in a VM then the dashboard will be running on your docker-environment host's IP. You can find your docker host IP by checking docker-machine's env vars, ex. with:

$ echo $DOCKER_HOST
tcp://192.168.99.100:2376
you would point your browser to http://192.168.99.100 or similar.
