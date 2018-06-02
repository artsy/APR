defmodule AprWeb.Gravity do
  use HTTPoison.Base

  def process_url(url) do
    Application.get_env(:apr, :gravity_api_url) <> url
  end

  def process_request_headers(_headers), do: Enum.into(%{"X-XAPP-TOKEN" => Application.get_env(:apr, :gravity_api_token)}, [])
  def process_response_body(body), do: Poison.decode!(body)
end