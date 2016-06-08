use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :apr, Apr.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :kafka_ex,
  brokers: [{"localhost", 9092}],
  consumer_group: System.get_env("KAFKA_CONSUMER_GROUP") || "kafka_ex",
  disable_default_worker: true,
  sync_timeout: 1000 #Timeout used synchronous requests from kafka. Defaults to 1000ms.
