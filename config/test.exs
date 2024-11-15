import Config

# Configure your database
#

# Print only warnings and errors during test
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :logger, level: :warning

config :ore, Ore.Repo,
  database: Path.expand("../ore_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ore_web, OreWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "G6UrTIj6fmgWw8CXAns5VBEa4fHQc5xauGvqy0v7r/OuugWiorlhCXtP1lnTI6nL",
  server: false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
