defmodule AprWeb.IncomingEventService do
  alias AprWeb.{InquiryEventService, PurchaseEventService}
  def process(topic, routing_key, event) do
    case topic do
      "inquiries" -> InquiryEventService.process(topic, routing_key, event)
      "purchases" -> PurchaseEventService.process(topic, routing_key, event)
    end
  end
end
