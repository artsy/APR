defmodule AprWeb.FeedController do
  use AprWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
