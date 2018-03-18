defmodule CheckersWeb.Router do
  use CheckersWeb, :router

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

  scope "/", CheckersWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/game/:game", PageController, :game
    get "/newchannel", PageController, :newchannel
    get "/deletechannel", PageController, :deletechannel
  end

  # Other scopes may use custom stacks.
   scope "/api/v1", CheckersWeb do
    pipe_through :api
    resources "/scores", ScoreController
   end
end
