defmodule AprWeb.Router do
  use AprWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BasicAuth, use_config: {:apr, :basic_auth}
  end

  scope "/", AprWeb do
    pipe_through :browser # Use the default browser stack

    get "/", FeedController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AprWeb do
  #   pipe_through :api
  # end
end
