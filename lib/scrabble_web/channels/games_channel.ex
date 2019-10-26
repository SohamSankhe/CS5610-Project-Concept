defmodule ScrabbleWeb.GamesChannel do
  use ScrabbleWeb, :channel

  defp authorized?(_payload) do
    true
  end

  # Todo Ref: Hangman example in class
  alias Scrabble.Game
  alias Scrabble.BackupAgent
  alias Scrabble.GameServer

  def join("games:" <> name, %{"player" => player}, socket) do
    if authorized?(%{}) do
      IO.inspect(name)
      IO.inspect(player)
      # start GameServer
      GameServer.start(name)
      # get server side game state
      game = GameServer.peek(name)
      # push name and player into socket
      socket = socket
      |> assign(:player, player)
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game, player)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

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
    player = socket.assigns[:player]
    game = GameServer.play(name, brd, brdInd, rckInd)
    # broadcast the new game state to other clients in the same channel
    if game.message == "" do
        broadcast!(socket, "update", %{"game" => Game.broadcast_view(game)})
    end
    {:reply, {:ok, %{ "game" => Game.client_view(game, player)}}, socket}
  end

  def handle_in("swap", %{"currentRackIndex" => currentRackIndex}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    game = GameServer.swap(name, currentRackIndex)
    # broadcast the new game state to other clients in the same channel
    if game.message == "" do
        broadcast!(socket, "update", %{"game" => Game.broadcast_view(game)})
    end
    {:reply, {:ok, %{ "game" => Game.client_view(game, player)}}, socket}
  end

  def handle_in("pass", %{"currentRackIndex" => currentRackIndex}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    game = GameServer.pass(name)
    # broadcast the new game state to other clients in the same channel
    broadcast!(socket, "update", %{"game" => Game.broadcast_view(game)})
    {:reply, {:ok, %{ "game" => Game.client_view(game, player)}}, socket}
  end

  def handle_in("forfeit", %{"currentRackIndex" => currentRackIndex}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    game = GameServer.forfeit(name)
    # broadcast the new game state to other clients in the same channel
    broadcast!(socket, "update", %{"game" => Game.broadcast_view(game)})
    {:reply, {:ok, %{ "game" => Game.client_view(game, player)}}, socket}
  end

  def handle_in("playAgain", %{"currentRackIndex" => currentRackIndex}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    game = GameServer.playAgain(name)
    # broadcast the new game state to other clients in the same channel
    broadcast!(socket, "update", %{"game" => Game.broadcast_view(game)})
    {:reply, {:ok, %{ "game" => Game.client_view(game, player)}}, socket}
  end

  def handle_in("chatMessage", %{"msg" => msg}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    game = GameServer.chatMessage(msg, name)
    broadcast!(socket, "update", %{"game" => Game.broadcast_view(game)})
    {:reply, :ok, socket}
  end





end
