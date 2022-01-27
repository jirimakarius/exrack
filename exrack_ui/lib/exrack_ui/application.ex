defmodule ExRackUI.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExRackUI.PromEx,
      ExRackUIWeb.Telemetry,
      {Phoenix.PubSub, name: ExRackUI.PubSub},
      ExRackUIWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ExRackUI.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ExRackUIWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
