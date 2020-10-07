defmodule Prequest.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Prequest.Repo,
      PrequestWeb.Telemetry,
      {Phoenix.PubSub, name: Prequest.PubSub},
      PrequestWeb.Endpoint,
      Prequest.Feed.Cache.Server
    ]

    opts = [strategy: :one_for_one, name: Prequest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PrequestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
