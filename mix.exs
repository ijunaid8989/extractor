defmodule Extractor.Mixfile do
  use Mix.Project

  def project do
    [app: :extractor,
     version: "0.0.1",
     elixir: "~> 1.7.1",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Extractor, []},
     applications: app_list(Mix.env)]
  end


  defp app_list(:dev), do: [:dotenv | app_list()]
  defp app_list(:test), do: [:dotenv | app_list()]
  defp app_list(_), do: app_list()
  defp app_list, do: [
    :phoenix,
    :phoenix_pubsub,
    :phoenix_html,
    :cowboy,
    :logger,
    :gettext,
    :phoenix_ecto,
    :postgrex,
    :tzdata,
    :ecto,
    :geo,
    :httpoison,
    :poison,
    :dotenv,
    :calendar,
    :mailgun,
    :jazz,
    :quantum,
    :porcelain
  ]


  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:calendar, "~> 0.17.4"},
      {:phoenix, "~> 1.3.3", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2.3"},
      {:exrm, github: "bitwalker/exrm"},
      {:postgrex, "~> 0.13.5"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:dotenv, "~> 2.1.0"},
      {:httpoison, github: "ijunaid8989/httpoison", override: true},
      {:poison, "~> 3.1.0", override: true},
      {:jazz, "~> 0.2.1"},
      {:ecto, "~> 2.1.4"},
      {:mailgun, github: "evercam/mailgun"},
      {:quantum, ">= 1.8.0"},
      {:porcelain, "~> 2.0"},
      {:relx, "~> 3.26.0"},
      {:geo, "~> 1.4"},
      {:erlware_commons, "~> 1.2.0"}
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
