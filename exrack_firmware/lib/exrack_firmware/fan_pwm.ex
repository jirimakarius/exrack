defmodule ExRack.FanPwm do
  @moduledoc false

  use GenServer

  # Client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def cycle(fan, cycle) do
    GenServer.cast(__MODULE__, {:cycle, fan, cycle})
  end

  def get_cycle(fan) do
    GenServer.call(__MODULE__, {:cycle, fan})
  end

  def get_cycle() do
    GenServer.call(__MODULE__, :cycle)
  end

  def config() do
    Application.fetch_env!(:exrack_firmware, ExRack.FanPwm)
  end

  # Server

  @impl true
  def init(data) do
    state =
      Enum.map(
        data,
        fn {k, v} ->
          invert = Map.get(v, :invert, false)
          cycle = Map.get(v, :cycle, 0)
          hardware = Map.get(v, :hardware, false)
          set_cycle(v.gpio, v.frequency, cycle, invert, hardware)

          :telemetry.execute([:fan, :pwm], %{percent: cycle}, %{
            frequency: v.frequency,
            fan: k
          })

          {k, Map.merge(v, %{:invert => invert, :cycle => cycle, :hardware => hardware})}
        end
      )

    {:ok, state}
  end

  @impl true
  def handle_cast({:cycle, fan, cycle}, state) do
    fan_state = Map.put(state[fan], :cycle, cycle)
    set_cycle(fan_state.gpio, fan_state.frequency, cycle, fan_state.invert, fan_state.hardware)

    :telemetry.execute([:fan, :pwm], %{percent: cycle}, %{
      frequency: fan_state.frequency,
      fan: fan
    })

    {:noreply, Keyword.put(state, fan, fan_state)}
  end

  @impl true
  def handle_call({:cycle, fan}, _from, state) do
    {:reply, state[fan].cycle, state}
  end

  @impl true
  def handle_call(:cycle, _from, state) do
    {:reply, Enum.map(state, fn {k, v} -> {k, v.cycle} end), state}
  end

  defp set_cycle(gpio, frequency, cycle, invert, hardware) do
    normalized_cycle = if invert, do: 1.0 - cycle, else: cycle

    if hardware do
      Pigpiox.Pwm.hardware_pwm(gpio, frequency, trunc(normalized_cycle * 1_000_000))
    else
      Pigpiox.Pwm.gpio_pwm(gpio, trunc(normalized_cycle * 255))
      Pigpiox.Pwm.set_pwm_frequency(gpio, frequency)
    end

    :ok
  end
end
