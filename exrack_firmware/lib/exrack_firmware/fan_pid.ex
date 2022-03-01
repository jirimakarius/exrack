defmodule ExRack.FanPID do
  @moduledoc false

  use GenServer

  # Client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def config do
    Application.fetch_env!(:exrack_firmware, ExRack.FanPID)
    |> Map.new()
  end

  # Server

  @impl true
  def init(state) do
    ExRack.DHT.subscribe()

    {:ok, Map.merge(%{integral: 0, max: nil, min: nil}, state)}
  end

  @impl true
  def handle_info({:dht, %{temperature: temperature, humidity: _}}, state) do
    {state, output} = pid(state, temperature)

    if output do
      ExRack.FanPwm.cycle(:nfa12, 0.6 + output)
    end

    {:noreply, state}
  end

  defp clamp(value, nil = _, nil = _), do: value
  defp clamp(value, max, nil = _) when value <= max, do: value
  defp clamp(value, nil = _, min) when value >= min, do: value
  defp clamp(value, _, min) when value < min, do: min
  defp clamp(value, max, _) when value > max, do: max
  defp clamp(value, _, _), do: value

  defp pid(
         %{kP: kP, kI: kI, kD: kD, setpoint: setpoint, integral: integral, max: max, min: min} =
           state,
         temperature
       ) do
    error = temperature - setpoint
    current_time = System.monotonic_time(:second)

    {state, output} =
      if Map.has_key?(state, :last_time) and Map.has_key?(state, :last_error) do
        delta_time = current_time - state.last_time
        delta_error = error - state.last_error

        i_term = integral + error * delta_time
        |>clamp(100.0, -100.0)
        d_term = delta_error / delta_time

        output =
          (kP * error + kI * i_term + kD * d_term)
          |> clamp(max, min)

        state = Map.put(state, :integral, integral)

        {state, output}
      else
        {state, nil}
      end

    state = Map.merge(state, %{last_time: current_time, last_error: error})

    {state, output}
  end
end
