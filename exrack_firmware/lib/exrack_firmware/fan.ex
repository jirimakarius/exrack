defmodule ExRack.Fan do
  @moduledoc false

  use GenServer

  # Client

  def start_link(%{:gpio => _gpio, :frequency => _frequency, :cycle => _cycle} = state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def cycle(cycle) do
    GenServer.cast(__MODULE__, {:cycle, cycle})
  end

  def get_cycle() do
    GenServer.call(__MODULE__, :cycle)
  end

  def config() do
    Application.fetch_env!(:exrack_firmware, ExRack.Fan)
    |> Map.new()
  end

  # Server

  @impl true
  def init(%{:gpio => gpio, :frequency => frequency, :cycle => cycle} = state) do
    Pigpiox.Pwm.hardware_pwm(gpio, frequency, cycle)

    {:ok, state}
  end

  @impl true
  def handle_cast({:cycle, cycle}, %{:gpio => gpio, :frequency => frequency}) do
    Pigpiox.Pwm.hardware_pwm(gpio, frequency, cycle)

    {:noreply, %{:gpio => gpio, :frequency => frequency, :cycle => cycle}}
  end

  @impl true
  def handle_call(:cycle, _from, %{:cycle => cycle} = state) do
    {:reply, cycle, state}
  end
end
