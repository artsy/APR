defmodule Apr.Service.BroadcastService do
  alias Apr.Endpoint

  def broadcast(message, topic) do
    processed_message = process_message(message)
    Endpoint.broadcast(topic, processed_message["verb"], processed_message)
  end

  defp process_message(message) do
    Poison.decode!(message)
      |> Map.take(["verb", "subject", "object", "properties"])
  end
end