defmodule ScrabbleWeb.GamesChannel do
  use ScrabbleWeb, :channel

  #def join("games:lobby", payload, socket) do
  #  if authorized?(payload) do
  #    {:ok, socket}
  #  else
  #    {:error, %{reason: "unauthorized"}}
  #  end
  #end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  #def handle_in("ping", payload, socket) do
  #  {:reply, {:ok, payload}, socket}
  #end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  #def handle_in("shout", payload, socket) do
  #  broadcast socket, "shout", payload
  #  {:noreply, socket}
  #end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  # Todo Ref: Hangman example in class
  alias Scrabble.Game
  alias Scrabble.BackupAgent

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      BackupAgent.put(name, game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # TODO remove
  def handle_in("guess", %{"letter" => ll}, socket) do
  	name = socket.assigns[:name]
  	{index, ""} = Integer.parse(ll)
    game = Game.guess(socket.assigns[:game], index)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("play", %{"board" => brd, "boardIndPlayed" => brdInd, "rackIndPlayed" => rckInd}, socket) do
    name = socket.assigns[:name]
    game = Game.play(socket.assigns[:game], brd, brdInd, rckInd)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

end
