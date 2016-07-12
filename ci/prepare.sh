#!/bin/bash

# Lifted from https://gist.github.com/joakimk/48ed80f1a7adb5f5ea27
# until CircleCI adds official Elixr/Erlang support https://discuss.circleci.com/t/add-support-for-elixir-erlang/2215

set -e

export ERLANG_VERSION="17.5"
export ELIXIR_VERSION="v1.0.5"

# If you have a elixir_buildpack.config, do this instead:
#export ERLANG_VERSION=$(cat elixir_buildpack.config | grep erlang_version | tr "=" " " | awk '{ print $2 }')
#export ELIXIR_VERSION=v$(cat elixir_buildpack.config | grep elixir_version | tr "=" " " | awk '{ print $2 }')

export INSTALL_PATH="$HOME/dependencies"

export ERLANG_PATH="$INSTALL_PATH/otp_src_$ERLANG_VERSION"
export ELIXIR_PATH="$INSTALL_PATH/elixir_$ELIXIR_VERSION"

mkdir -p $INSTALL_PATH
cd $INSTALL_PATH

# Install erlang
if [ ! -e $ERLANG_PATH/bin/erl ]; then
  curl -OL http://www.erlang.org/download/otp_src_$ERLANG_VERSION.tar.gz
  tar xzf otp_src_$ERLANG_VERSION.tar.gz
  cd $ERLANG_PATH
  ./configure --enable-smp-support \
              --enable-m64-build \
              --disable-native-libs \
              --disable-sctp \
              --enable-threads \
              --enable-kernel-poll \
              --disable-hipe \
              --without-javac
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ERLANG_PATH $INSTALL_PATH/erlang
fi

# Install elixir
export PATH="$ERLANG_PATH/bin:$PATH"

if [ ! -e $ELIXIR_PATH/bin/elixir ]; then
  git clone https://github.com/elixir-lang/elixir $ELIXIR_PATH
  cd $ELIXIR_PATH
  git checkout $ELIXIR_VERSION
  make

  # Symlink to make it easier to setup PATH to run tests
  ln -sf $ELIXIR_PATH $INSTALL_PATH/elixir
fi

export PATH="$ERLANG_PATH/bin:$ELIXIR_PATH/bin:$PATH"

# Install package tools
if [ ! -e $HOME/.mix/rebar ]; then
  yes Y | LC_ALL=en_GB.UTF-8 mix local.hex
  yes Y | LC_ALL=en_GB.UTF-8 mix local.rebar
fi

# Generate a release for the given environment
export MIX_ENV=$APR_RELEASE_ENVIRONMENT

# Fetch and compile dependencies
cd $HOME/$CIRCLE_PROJECT_REPONAME

mix deps.get
mix deps.compile

npm install

# Set compile-time environment vars - secrets here should be injected from CircleCI configuration
export BASIC_AUTH_USER=$APR_BASIC_AUTH_USER
export BASIC_AUTH_PASSWORD=$APR_BASIC_AUTH_PASSWORD

# Compile application code
mix compile
node node_modules/brunch/bin/brunch build --production
mix phoenix.digest

# Build release
mix release

# Upload release to S3
RELEASE_BUNDLE=apr-$APR_RELEASE_ENVIRONMENT-$CIRCLE_SHA1.tgz
tar cvzf $RELEASE_BUNDLE rel
aws s3 cp $RELEASE_BUNDLE s3://artsy-deploy/apr/$RELEASE_BUNDLE
aws s3 cp $RELEASE_BUNDLE s3://artsy-deploy/apr/latest

# clean up
rm -rf _build/ && rm -rf rel/
