defmodule AprWeb.FeedControllerTest do
  use AprWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = conn
            |> put_req_header("authorization", "Basic " <> Base.encode64("sample:sample"))
            |> get("/")
    assert html_response(conn, 200) =~ "Artsy Public Radio"
  end
end
