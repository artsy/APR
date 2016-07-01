defmodule Apr.EventChannel do
  use Phoenix.Channel

  def join(topic, _message, socket) do
    {:ok, socket}
  end

  def handle_in(topic, %{"object" => object, "verb" => verb, "subject" => subject, "properties" => properties}, socket) do
    broadcast! socket, topic, %{object: object, verb: verb, subject: subject, properties: properties}
    {:noreply, socket}
  end

end