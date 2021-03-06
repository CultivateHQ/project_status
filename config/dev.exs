use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :project_status, ProjectStatus.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch"]]

# Watch static and templates for browser reloading.
config :project_status, ProjectStatus.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :project_status, ProjectStatus.Repo,
  adapter: Ecto.Adapters.Postgres,
  # username: System.get_env("POSTGRES_USER"),
  # password: System.get_env("POSTGRES_PASSWORD"),
  database: "project_status_dev",
  pool_size: 10 # The amount of database connections in the pool

config :guardian, Guardian,
  issuer: "ProjectStatus",
  ttl: { 30, :days },
  secret_key: "JqTPmxSIJfyBhqOiiLap+5vTq7HEHl0HnVl8b7cdskZD/dajdYSnBYnCVHE29ngX",
  serializer: ProjectStatus.GuardianSerializer

import_config "config.secret*.exs"
