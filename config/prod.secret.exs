use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :extractor, Extractor.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :extractor, Extractor.Repo,
  adapter: Ecto.Adapters.Postgres,
  extensions: [
    {Extractor.Types.JSON.Extension, library: Poison}
  ],
  url: System.get_env("DATABASE_URL"),
  socket_options: [keepalive: true],
  timeout: 60_000,
  pool_timeout: 60_000,
  pool_size: 80,
  lazy: false,
  ssl: true
