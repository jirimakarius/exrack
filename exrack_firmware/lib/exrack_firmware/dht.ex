defmodule ExRack.DHT do
  @moduledoc false

  use GenServer

  @period 10_000

  # Client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def config do
    Application.fetch_env!(:exrack_firmware, ExRack.DHT)
    |> Map.new()
  end

  def temperature do
    GenServer.call(__MODULE__, :temperature)
  end

  def humidity do
    GenServer.call(__MODULE__, :humidity)
  end

  def data do
    GenServer.call(__MODULE__, :data)
  end

  # Server

  @impl true
  def init(state) do
    state =
      state
      |> Map.merge(%{temperature: nil, humidity: nil})

    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, %{:gpio => gpio, :sensor => sensor} = state) do
    state =
      case DHT.read(gpio, sensor) do
        {:ok, %{:humidity => humidity, :temperature => temperature}} ->
          :telemetry.execute([:dht, :humididty], %{percent: humidity}, %{sensor: sensor})
          :telemetry.execute([:dht, :temperature], %{celsius: temperature}, %{sensor: sensor})
          Map.merge(state, %{:temperature => temperature, :humidity => humidity})

        _ ->
          state
      end

    schedule_work()

    {:noreply, state}
  end

  @impl true
  def handle_call(:temperature, _from, %{:temperature => temperature} = state) do
    {:reply, temperature, state}
  end

  @impl true
  def handle_call(:humidity, _from, %{:humidity => humidity} = state) do
    {:reply, humidity, state}
  end

  @impl true
  def handle_call(:data, _from, %{:humidity => humidity, :temperature => temperature} = state) do
    {:reply, %{:temperature => temperature, :humidity => humidity}, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, @period)
  end
end
