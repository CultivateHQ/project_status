use Mix.Config
config :project_status, ProjectStatus.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [host: "cultiprojectstatus.herokuapp.com"],
  cache_static_manifest: "priv/static/manifest.json"

config :logger, level: :info

#import_config "prod.secret.exs"

config :project_status, ProjectStatus.Endpoint,
       secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :project_status, ProjectStatus.Repo,
       adapter: Ecto.Adapters.Postgres,
       url: System.get_env("DATABASE_URL"),
       pool_size: 20


config :basic_auth, username: System.get_env("BASIC_AUTH_USER"), password: System.get_env("BASIC_AUTH_PASSWORD")

config :project_status,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_key: System.get_env("MAILGUN_KEY")
