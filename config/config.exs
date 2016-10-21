# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :extractor,
  ecto_repos: [Extractor.Repo]

# Configures the endpoint
config :extractor, Extractor.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lRoG72jFhhH8KDyZWplVrAiB/3c47xI+6+ywBPR7FQnPk2ptTzVsr12Sc9isp+GV",
  render_errors: [view: Extractor.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Extractor.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :extractor, :mailgun,
  mailgun_domain: System.get_env("MAILGUN_DOMAIN"),
  mailgun_key: System.get_env("MAILGUN_KEY")

config :extractor, :mailgun,
  domain: "sandbox",
  key: "sandbox",
  mode: :test,
  test_file_path: "priv_dir/mailgun_test.json"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
