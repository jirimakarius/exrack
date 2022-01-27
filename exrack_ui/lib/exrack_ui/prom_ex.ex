defmodule ExRackUI.PromEx do
  @moduledoc false

  use PromEx, otp_app: :exrack_ui

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix, router: ExRackUIWeb.Router, endpoint: ExRackUIWeb.Endpoint},
      # Plugins.Ecto,
      # Plugins.Oban,
      Plugins.PhoenixLiveView
      # Plugins.Absinthe,
      # Plugins.Broadway,
    ] ++ Application.fetch_env!(:exrack_ui, ExRackUI.PromEx)[:plugins]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "Prometheus",
      default_selected_interval: "30s"
    ]
  end

  @impl true
  def dashboards do
    [
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "phoenix.json"},
      # {:prom_ex, "ecto.json"},
      # {:prom_ex, "oban.json"},
      {:prom_ex, "phoenix_live_view.json"}
      # {:prom_ex, "absinthe.json"},
      # {:prom_ex, "broadway.json"},
    ]
  end
end
