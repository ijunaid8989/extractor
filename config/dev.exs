use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :extractor, ExtractorWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :extractor, ExtractorWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ],
  email: "evercam.io <env.dev@evercam.io>"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Sending email on start and end of Extractor
config :extractor, :send_emails_for_extractor, false

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :extractor, :mailgun,
  domain: "dev",
  key: "dev",
  mode: :dev

# Configure your database
config :extractor, Extractor.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Extractor.PostgresTypes,
  username: "postgres",
  password: "postgres",
  database: System.get_env["db"] || "evercam_dev",
  pool_size: 10
