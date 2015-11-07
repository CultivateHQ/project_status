use Mix.Config
config :project_status, ProjectStatus.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [host: "projectstatus.cultivatehq.com"],
  cache_static_manifest: "priv/static/manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
