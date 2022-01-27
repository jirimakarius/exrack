defmodule ExRack.FanPwm do
  @moduledoc false

  use GenServer

  # Client

  def start_link(%{:gpio => _gpio, :frequency => _frequency} = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def cycle(cycle) do
    GenServer.cast(__MODULE__, {:cycle, cycle})
  end

  def get_cycle() do
    GenServer.call(__MODULE__, :cycle)
  end

  def config() do
    Application.fetch_env!(:exrack_firmware, ExRack.FanPwm)
    |> Map.new()
  end

  # Server

  @impl true
  def init(%{:gpio => gpio, :frequency => frequency} = state) do
    invert = Map.get(state, :invert, false)
    cycle = Map.get(state, :cycle, 0)
    normalized_cycle = if invert, do: 1_000_000 - cycle, else: cycle
    Pigpiox.Pwm.hardware_pwm(gpio, frequency, normalized_cycle)
    :telemetry.execute([:fan, :pwm], %{percent: cycle / 10_000}, %{frequency: frequency})

    {:ok, Map.merge(state, %{:invert => invert, :cycle => cycle})}
  end

  @impl true
  def handle_cast({:cycle, cycle}, %{:gpio => gpio, :frequency => frequency, :invert => invert}) do
    normalized_cycle = if invert, do: 1_000_000 - cycle, else: cycle
    Pigpiox.Pwm.hardware_pwm(gpio, frequency, normalized_cycle)
    :telemetry.execute([:fan, :pwm], %{percent: cycle / 10_000}, %{frequency: frequency})

    {:noreply, %{:gpio => gpio, :frequency => frequency, :cycle => cycle, :invert => invert}}
  end

  @impl true
  def handle_call(:cycle, _from, %{:cycle => cycle} = state) do
    {:reply, cycle, state}
  end
end
