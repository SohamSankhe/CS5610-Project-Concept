defmodule ScrabbleWeb.PageController do
  use ScrabbleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, %{"name" => name, "player" => player}) do
    render conn, "game.html", name: name, player: player
  end
  
  def redirectToGame(conn, %{"x" => x}) do
  	redUr1 = "\/games\/" <> x
  	redirect(conn, to: redUr1)
  end
end
