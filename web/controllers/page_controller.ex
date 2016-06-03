defmodule Apr.PageController do
  use Apr.Web, :controller

  plug BasicAuth, realm: "Admin Area", username: "admin", password: "secret"

  def index(conn, _params) do
    render conn, "index.html"
  end
end
