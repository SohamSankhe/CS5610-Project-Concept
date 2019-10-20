defmodule ScrabbleWeb.IndexChannel do
  use ScrabbleWeb, :channel

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  alias Scrabble.Game
  alias Scrabble.BackupAgent

  def join("index:" <> _name, payload, socket) do
    if authorized?(payload) do
      game_name = BackupAgent.get_keys  //get all of the name of existing games; if there is no existing game, then return an empty array
      socket = socket   //save the array of the game_name in socket
      |> assign(:game_name, game_name)
      {:ok, %{"game_name" => game_name}, socket}    //return the array of game name to index.jsx
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("add", %{"name" => name}, socket) do    //add the new game_name to socket and add the new game name and its game state into the backup end
      game_name = socket.assigns[:game_name]
      game_name = [name|game_name]
      socket = assign(socket, :game_name, game_name)
      game = Game.new
      BackupAgent.put(name, game)
      {:reply, {:ok, %{ "resp" => "game has been saved"}}, socket}
  end

end
