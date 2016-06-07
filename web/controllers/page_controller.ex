defmodule Apr.PageController do
  use Apr.Web, :controller

  plug BasicAuth, Application.get_env(:apr, :basic_auth)

  def index(conn, _params) do
    render conn, "index.html"
  end
end
