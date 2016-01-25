# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :project_status, ProjectStatus.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "6ybSNehsndY6puKPgo3sV8A0LWjdtbJZRFTzdXJyIU9rwO9DGW/bF9WomV2WQebc",
  debug_errors: false,
  pubsub: [name: ProjectStatus.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth, providers: [
  github: {Ueberauth.Strategy.Github, [default_scope: "read:org"]}
]

config :project_status, :authorisation_github_team_id, 973593

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# This line was automatically added by ansible-elixir-stack setup script
if System.get_env("SERVER") do
  config :phoenix, :serve_endpoints, true
end
