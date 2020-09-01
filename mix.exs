defmodule Prequest.MixProject do
  use Mix.Project

  def project do
    [
      app: :prequest,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      preferred_cli_env: [ci: :test],
      deps: deps(),

      # Docs
      name: "Prequest",
      source_url: "https://github.com/felipelincoln/prequest",
      homepage_url: "https://prequest.herokuapp.com/",
      docs: [
        output: "docs",
        main: "Prequest",
        extras: ["README.md", ".github/CONTRIBUTING.md", "docs/guides/boilerplate.md"],
        groups_for_extras: [guides: [".github/CONTRIBUTING.md", "docs/guides/boilerplate.md"]],
        groups_for_modules: [
          channels: [PrequestWeb.UserSocket],
          live: [PrequestWeb.PageLive],
          views: [PrequestWeb.ErrorHelpers, PrequestWeb.ErrorView, PrequestWeb.LayoutView]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Prequest.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.13.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_doc, "~>0.22", only: :dev, runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.8", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      ci: ["format --check-formatted --dry-run", "credo --strict", "sobelow -v", "test"]
    ]
  end
end
