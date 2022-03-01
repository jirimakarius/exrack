defmodule ExRack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExRack.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: ExRack.Worker.start_link(arg)
        # {ExRack.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: ExRack.Worker.start_link(arg)
      # {ExRack.Worker, arg},
    ]
  end

  def children(_target) do
    [
      {ExRack.FanPwm, ExRack.FanPwm.config()},
      {ExRack.FanRpm, ExRack.FanRpm.config()},
#      {ExRack.DHT, ExRack.DHT.config()},
#      {ExRack.FanPID, ExRack.FanPID.config()}
    ]
  end

  def target() do
    Application.get_env(:exrack_firmware, :target)
  end
end
