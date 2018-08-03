use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :extractor, ExtractorWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :extractor, :mailgun,
  domain: "sandbox",
  key: "sandbox",
  mode: :test,
  test_file_path: "priv_dir/mailgun_test.json"

# Configure your database
config :extractor, Extractor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "extractor_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
