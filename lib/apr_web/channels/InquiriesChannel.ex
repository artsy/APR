defmodule AprWeb.InquiriesChannel do
  use Phoenix.Channel

  def join(_topic, _message, socket) do
    {:ok, socket}
  end

  def handle_in(routing_key, %{"object" => object, "verb" => verb, "subject" => subject, "properties" => properties}, socket) do
    IO.puts "Consuming an event IIII"
    broadcast! socket, routing_key, %{object: object, verb: verb, subject: subject, properties: properties}
    {:noreply, socket}
  end
end