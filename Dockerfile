FROM marcelocg/phoenix:latest

RUN mix local.hex --force
ADD . /app
WORKDIR /app
CMD mix phoenix.server -b 0.0.0.0 -p 80