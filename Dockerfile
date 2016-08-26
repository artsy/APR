FROM elixir

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

ADD . /app
WORKDIR /app
ENV PORT 8081
ENV MIX_ENV prod
RUN mix deps.get
CMD mix phoenix.server
