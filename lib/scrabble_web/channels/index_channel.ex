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
      # get all of the name of existing games; if there is no existing game, then return an empty array
      game_name = BackupAgent.get_keys
      # save the array of the game_name in socket
      # return the array of game name to index.jsx
      {:ok, %{"game_name" => game_name}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # add the new game_name to socket and add the new game name and its game state into the backup agent
  def handle_in("add", %{"name" => name}, socket) do
      game_name = BackupAgent.get_keys
      game_name = [name|game_name]
      broadcast!(socket, "update", %{"game_name" => game_name})
      game = Game.new
      BackupAgent.put(name, game)
      {:reply, {:ok, %{ "resp" => "game has been saved"}}, socket}
  end

end
