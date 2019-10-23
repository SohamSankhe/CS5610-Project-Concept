defmodule ScrabbleWeb.GamesChannel do
  use ScrabbleWeb, :channel


  defp authorized?(_payload) do
    true
  end

  # Todo Ref: Hangman example in class
  alias Scrabble.Game
  alias Scrabble.BackupAgent
  alias Scrabble.GameServer

  def join("games:" <> name_player, payload, socket) do
    if authorized?(payload) do
      name_player = String.split(name_player, ",")
      name = List.first(name_player)
      IO.inspect(name)
      player = List.last(name_player)
      IO.inspect(player)
      game = BackupAgent.get(name)|| Game.new()
      BackupAgent.put(name, game)
      rack = Game.check_player(player, game)
      game = game
      |> Map.delete(:rack1)
      |> Map.delete(:rack2)
      |> Map.put_new(:rack, rack)
      socket = socket
      |> assign(:rack, rack)
      |> assign(:player, player)
      |> assign(:name, name)
      GameServer.start(name)
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
