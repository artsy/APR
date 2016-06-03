# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :apr, Apr.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "JzrxjhEfoUbTOX38unZPfTvfyreAgKQkzRozn5mheqBUU1sSmUCDsuZL7Kl8Lt9R",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Apr.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :kafka_ex,
  # expected to be comma separated list of broker_host:port
  brokers: System.get_env("KAFKA_BROKERS")
            |> String.split(",")
            |> Enum.map(fn(broker)-> List.to_tuple(String.split(broker, ":")) end ),
  consumer_group: System.get_env("KAFKA_CONSUMER_GROUP"),
  disable_default_worker: true,
  sync_timeout: 1000 #Timeout used synchronous requests from kafka. Defaults to 1000ms.

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"


