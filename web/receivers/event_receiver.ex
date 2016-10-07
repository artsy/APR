defmodule Apr.EventReceiver do
  require Logger

  alias Apr.Endpoint

  def start_link(channel) do
    KafkaEx.create_worker(String.to_atom(channel))
    for message <- KafkaEx.stream(channel, 0, worker_name: String.to_atom(channel), offset: latest_offset(channel)), acceptable_message?(message.value) do
      proccessed_message = process_message message
      # broadcast a message to a channel
      Endpoint.broadcast("#{channel}", proccessed_message["verb"], proccessed_message)
    end
  end

  defp latest_offset(channel) do
    KafkaEx.latest_offset(channel, 0)
        |> List.first
        |> Map.get(:partition_offsets)
        |> List.first
        |> Map.get(:offset)
        |> List.first
  end

  def acceptable_message?(message) do
    try do
      Poison.decode!(message)
        |> is_map
    rescue
      Poison.SyntaxError -> false
    end
  end

  def process_message(message) do
    Poison.decode!(message.value)
      |> Map.take(["verb", "subject", "object", "properties"])
  end
end