#!/bin/bash

# CircleCI has no official Elixr/Erlang support https://discuss.circleci.com/t/add-support-for-elixir-erlang/2215
if [ ! -e /usr/local/bin/elixir ]; then
  # Install erlang / elixir
  wget -O /tmp/erlang-solutions_1.0_all.deb https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
  sudo dpkg -i /tmp/erlang-solutions_1.0_all.deb
  sudo apt-get update

  # Workaround, otherwise apt-get install esl-erlang fails
  sudo rm -rf /etc/rc2.d/K80couchdb

  sudo apt-get install esl-erlang
  sudo apt-get install elixr
fi

# Install package tools
if [ ! -e $HOME/.mix/rebar ]; then
  mix local.hex --force
  mix local.rebar --force
fi
