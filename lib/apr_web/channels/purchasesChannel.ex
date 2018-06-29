defmodule AprWeb.PurchasesChannel do
  use Phoenix.Channel

  def join(_topic, _message, socket) do
    {:ok, socket}
  end

  def handle_in(routing_key, payload, socket) do
    broadcast! socket, routing_key, payload
    {:noreply, socket}
  end
end