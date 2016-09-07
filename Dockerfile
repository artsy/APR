FROM elixir

ARG BASIC_AUTH_USER
ARG BASIC_AUTH_PASSWORD

RUN mix local.hex --force
RUN mix local.rebar --force

ENV PHOENIX_VERSION 1.2.0

# install the Phoenix Mix archive
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-$PHOENIX_VERSION.ez

RUN apt-get update && \
      apt-get -y install sudo

# install Node.js (>= 6.0.0) and NPM in order to satisfy brunch.io dependencies
# See http://www.phoenixframework.org/docs/installation#section-node-js-5-0-0-
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && apt-get update && sudo apt-get install -y nodejs

RUN apt-get -y install nginx
RUN rm -v /etc/nginx/nginx.conf
RUN rm -v /etc/nginx/sites-enabled/default
ADD conf/nginx.conf /etc/nginx/
ADD conf/apr-backend.conf /etc/nginx/conf.d/

ADD . /app
WORKDIR /app
ENV PORT 4000
ENV MIX_ENV prod
RUN mix deps.get
RUN mix compile
RUN npm install
RUN node node_modules/brunch/bin/brunch build --production
RUN mix phoenix.digest
CMD service nginx start && mix phoenix.server
