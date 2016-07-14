#!/bin/bash

# CircleCI has no official Elixr/Erlang support https://discuss.circleci.com/t/add-support-for-elixir-erlang/2215

ERLANG_VERSION=1:18.3
ELIXIR_VERSION=1.2.4-1

# Install erlang / elixir
wget -O /tmp/erlang-solutions_1.0_all.deb https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i /tmp/erlang-solutions_1.0_all.deb
sudo apt-get update

# Workaround, otherwise apt-get install esl-erlang fails
sudo rm -rf /etc/rc2.d/K80couchdb

sudo apt-get install esl-erlang=$ERLANG_VERSION
sudo apt-get install elixir=$ELIXIR_VERSION

export MIX_ENV=prod

mix local.hex --force
mix local.rebar --force

# Fetch dependencies before CircleCI infers an npm install from our package.json
mix deps.get
