use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :project_status, ProjectStatus.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :project_status, ProjectStatus.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  # username: System.get_env("POSTGRES_USER"),
  # password: System.get_env("POSTGRES_PASSWORD"),
  database: "project_status_test",
  size: 1 # Use a single connection for transactional tests
