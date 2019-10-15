defmodule ScrabbleWeb.PageController do
  use ScrabbleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
