# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :apr, AprWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4kX0iW1s4jFKredRekJIh9paPjdJJIxc1XYlel+SDtIYLRjS1RxqxWnLEfqeZEF2",
  render_errors: [view: AprWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Apr.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :apr, RabbitMQ,
  username: System.get_env("RABBITMQ_USER"),
  password: System.get_env("RABBITMQ_PASSWORD"),
  host: System.get_env("RABBITMQ_HOST"),
  heartbeat: 5

config :apr, basic_auth: [
  username: System.get_env("BASIC_AUTH_USER"),
  password: System.get_env("BASIC_AUTH_PASSWORD"),
  realm: "Admin Area"
]

config :apr,
  gravity_api_url: System.get_env("GRAVITY_API_URL"),
  gravity_api_token: System.get_env("GRAVITY_API_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
