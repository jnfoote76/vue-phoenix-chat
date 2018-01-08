defmodule Vuechat.Router do
  use Vuechat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Vuechat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Vuechat do
    pipe_through :api
    resources "/rooms", RoomController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Vuechat do
  #   pipe_through :api
  # end
end
