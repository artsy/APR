defmodule AprWeb.IncomingEventService do
  def process(topic, routing_key, event) do
    case routing_key do
      "artworkinquiryrequest.inquired" ->

        # require IEx
        # IEx.pry

        # fetch artwork
        artwork_task = Task.async(fn -> AprWeb.Gravity.get!("/v1/artwork/#{event["properties"]["inquireable"]["id"]}") end)
        # fetch user location
        user_task = Task.async(fn -> AprWeb.Gravity.get!("/v1/user/#{event["properties"]["inquirer"]["id"]}") end)
        # fetch partner locations

        artwork = Task.await(artwork_task)
        partner_task = Task.async(fn -> AprWeb.Gravity.get!("/v1/partner/#{artwork.body["partner"]["_id"]}") end)
        partner_locations_task = Task.async(fn -> AprWeb.Gravity.get!("/v1/partner/#{artwork.body["partner"]["_id"]}/locations") end)
        data = Map.merge(event, %{ "partner": Task.await(partner_task).body, "partner_locations": Task.await(partner_locations_task).body, "artwork": artwork.body, "user": Task.await(user_task).body})
        AprWeb.Endpoint.broadcast(topic, routing_key, data)
    end
  end
end
