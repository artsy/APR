defmodule AprWeb.PurchaseEventService do
  def process(topic, routing_key, event) do
    # fetch artwork
    artwork_task = Task.async(fn -> AprWeb.Gravity.get!("/v1/artwork/#{event["properties"]["artwork"]["id"]}") end)
    # fetch user location
    user_task = Task.async(fn -> AprWeb.Gravity.get!("/v1/user/#{event["subject"]["id"]}") end)
    # fetch partner locations
    partner_locations_task = Task.async(fn -> AprWeb.Gravity.get!("/v1/partner/#{event["properties"]["partner"]["id"]}/locations") end)
    data = Map.merge(event, %{ "partner_locations": Task.await(partner_locations_task).body, "artwork": Task.await(artwork_task).body, "user": Task.await(user_task).body})
    AprWeb.Endpoint.broadcast(topic, routing_key, data)
  end
end