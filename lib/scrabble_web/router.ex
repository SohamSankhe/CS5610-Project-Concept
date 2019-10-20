defmodule ScrabbleWeb.Router do
  use ScrabbleWeb, :router

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

  scope "/", ScrabbleWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/games/:name/:player", PageController, :game
    post "/redirectToGame", PageController, :redirectToGame
  end

  # Other scopes may use custom stacks.
  # scope "/api", ScrabbleWeb do
  #   pipe_through :api
  # end
end
