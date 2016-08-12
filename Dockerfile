FROM marcelocg/phoenix:latest

RUN mix local.hex --force
ADD . /app
WORKDIR /app
ENV PORT 80
CMD mix phoenix.server