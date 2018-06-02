defmodule AprWeb.InquiriesChannel do
  use Phoenix.Channel

  def join(_topic, _message, socket) do
    {:ok, socket}
  end

  def handle_in("artworkinquiryrequest.inquired", payload, socket) do
    broadcast! socket, "artworkinquiryrequest.inquired", payload
    {:noreply, socket}
  end
end