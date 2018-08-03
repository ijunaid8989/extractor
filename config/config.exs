# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :extractor, base_url: "https://api.dropboxapi.com/2"
config :extractor, upload_url: "https://content.dropboxapi.com/2/"

# General application configuration
config :extractor,
  ecto_repos: [Extractor.Repo]

# Configures the endpoint
config :extractor, ExtractorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lRoG72jFhhH8KDyZWplVrAiB/3c47xI+6+ywBPR7FQnPk2ptTzVsr12Sc9isp+GV",
  render_errors: [view: Extractor.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Extractor.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :quantum,
  cron: [
    snapshot_extraction: [
      task: {"Extractor.StartExtractor", "start"},
      schedule: "*/2 * * * *",
      overlap: false
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
