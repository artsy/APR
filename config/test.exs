use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :apr, Apr.Endpoint,
  http: [port: 4001],
  server: false

config :apr, :basic_auth, [
  realm: "Admin Area",
  username: "sample",
  password: "sample"
]

# Print only warnings and errors during test
config :logger, level: :warn
