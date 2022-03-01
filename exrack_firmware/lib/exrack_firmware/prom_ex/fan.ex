defmodule ExRack.PromEx.Fan do
  use PromEx.Plugin

  @impl true
  def event_metrics(_) do
    Event.build(
      :dht,
      [
        last_value(
          [:exrack, :fan, :rpm],
          event_name: [:fan, :rpm],
          measurement: :rpm,
          description: "Fan RPM",
          tags: [:fan]
        ),
        last_value(
          [:exrack, :fan, :pwm, :percent],
          event_name: [:fan, :pwm],
          measurement: :percent,
          description: "Percentage of Fan PWM cycle",
          tags: [:frequency, :fan]
        )
      ]
    )
  end
end
