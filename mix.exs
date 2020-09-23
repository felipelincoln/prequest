defmodule Prequest.MixProject do
  use Mix.Project

  def project do
    [
      name: "Prequest",
      source_url: "https://github.com/felipelincoln/prequest",
      homepage_url: "https://prequest.herokuapp.com/",
      app: :prequest,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [ci: :test, "ecto.reset.test": :test, coveralls: :test],
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      mod: {Prequest.Application, []},
      extra_applications: [:logger, :runtime_tools, :ssl]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.13.0"},
      {:floki, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_doc, "~>0.22", runtime: false},
      {:credo, "~> 1.4", runtime: false},
      {:sobelow, "~> 0.8"},
      {:excoveralls, "~> 0.13"}
    ]
  end

  defp docs do
    [
      output: "docs",
      api_reference: false,
      main: "contributing",
      filter_prefix: "Prequest.",
      extras: [".github/CONTRIBUTING.md"],
      nest_modules_by_prefix: [Prequest, Prequest.CMS, Prequest.Accounts],
      groups_for_functions: [
        "Managing articles": &(&1[:section] == :article),
        "Managing topics": &(&1[:section] == :topic),
        "Managing reports": &(&1[:section] == :report),
        "Managing views": &(&1[:section] == :view)
      ]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.reset.test": ["ecto.reset"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      ci: ["format --check-formatted --dry-run", "credo --strict", "sobelow -v", "coveralls"]
    ]
  end
end
