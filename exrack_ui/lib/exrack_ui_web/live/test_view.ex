defmodule ExRackUIWeb.TestView do
  use ExRackUIWeb, :live_view

  def render(assigns) do
    ~H"""
    Current temperature: <%= @temperature %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1_000)

    {:ok, assign(socket, temperature: Time.utc_now())}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1_000)
    {:noreply, assign(socket, temperature: Time.utc_now())}
  end
end
