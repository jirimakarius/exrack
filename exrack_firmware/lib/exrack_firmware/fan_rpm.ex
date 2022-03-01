defmodule ExRack.FanRpm do
  @moduledoc false

  use GenServer

  @period 5_000

  # Client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def rpm(fan) do
    GenServer.call(__MODULE__, {:rpm, fan})
  end

  def rpm() do
    GenServer.call(__MODULE__, :rpm)
  end

  def config() do
    Application.fetch_env!(:exrack_firmware, ExRack.FanRpm)
  end

  def subscribe() do
    GenServer.call(__MODULE__, :subscribe)
  end

  # Server

  @impl true
  def init(data) do
    reference_map =
      Enum.map(
        data,
        fn {k, v} ->
          {:ok, reference} = Circuits.GPIO.open(v, :input, [{:pull_mode, :pullup}])
          Circuits.GPIO.set_interrupts(reference, :falling, [{:suppress_glitches, true}])

          {k, reference}
        end
      )

    state = %{
      :fans =>
        Enum.map(data, fn {k, v} ->
          {k, %{gpio: v, rpm: 0, cycles: 0, reference: reference_map[k]}}
        end),
      :subscribed => []
    }

    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_call({:rpm, fan}, _from, state) do
    {:reply, state.fans[fan].rpm, state}
  end

  @impl true
  def handle_call(:rpm, _from, state) do
    {:reply, Enum.map(state.fans, fn {k, v} -> {k, v.rpm} end), state}
  end

  @impl true
  def handle_call(:subscribe, {pid, _}, state) do
    subscribed_state = [state.subscribed | pid]

    {:reply, :ok, Map.put(state, :subscribed, subscribed_state)}
  end

  @impl true
  def handle_info(:work, state) do
    fan_state =
      Enum.map(state.fans, fn {k, v} ->
        rpm = v.cycles * 1_000 * 30 / @period
        :telemetry.execute([:fan, :rpm], %{rpm: rpm}, %{fan: k})

        {k, Map.merge(v, %{rpm: rpm, cycles: 0})}
      end)

    schedule_work()

    {:noreply, Map.put(state, :fans, fan_state)}
  end

  @impl true
  def handle_info({:circuits_gpio, pin_number, _timestamp, _value}, state) do
    fan_state =
      Enum.map(state.fans, fn {k, v} ->
        case v.gpio do
          ^pin_number ->
            {k, Map.put(v, :cycles, v.cycles + 1)}

          _ ->
            {k, v}
        end
      end)

    {:noreply, Map.put(state, :fans, fan_state)}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @period)
  end
end
