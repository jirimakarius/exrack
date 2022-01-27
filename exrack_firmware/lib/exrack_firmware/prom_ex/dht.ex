defmodule ExRack.PromEx.DHT do
  use PromEx.Plugin

  @impl true
  def event_metrics(_) do
    Event.build(
      :dht,
      [
        last_value(
          [:exrack, :dht, :humididty, :percent],
          event_name: [:dht, :humididty],
          measurement: :percent,
          description: "Percentage of relative humidity",
          tags: [:sensor]
        ),
        last_value(
          [:exrack, :dht, :temperature, :celsius],
          event_name: [:dht, :temperature],
          measurement: :celsius,
          description: "Temperature in celsius",
          tags: [:sensor]
        )
      ]
    )
  end
end
