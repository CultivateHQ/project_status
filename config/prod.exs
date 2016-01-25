use Mix.Config
config :project_status, ProjectStatus.Endpoint,
  http: [port: 3002],
  url: [host: "projectstatus.cultivatehq.com"],
  cache_static_manifest: "priv/static/manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"

config :guardian, Guardian,
  issuer: "ProjectStatus",
  ttl: { 30, :days },
  secret_key: "JqTPmxSIJfyBhqOiiLap+5vTq7HEHl0HnVl8b7cdskZD/dajdYSnBYnCVHE29ngX",
  serializer: ProjectStatus.GuardianSerializer
