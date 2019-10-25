defmodule Scrabble.GameServer do
  use GenServer

  def reg(name) do
    {:via, Registry, {Scrabble.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    Scrabble.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = Scrabble.BackupAgent.get(name) || Scrabble.Game.new()
    # push server side game state into BackupAgent
    Scrabble.BackupAgent.put(name, game)
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def play(name, board, boardIndPlayed, rackIndPlayed) do
    GenServer.call(reg(name), {:play, name, board, boardIndPlayed, rackIndPlayed})
  end

  def swap(name, currentRackIndex) do
    GenServer.call(reg(name), {:swap, name, currentRackIndex})
  end

  def pass(name) do
    GenServer.call(reg(name), {:pass, name})
  end

  def forfeit(name) do
    GenServer.call(reg(name), {:forfeit, name})
  end

  def playAgain(name) do
    GenServer.call(reg(name), {:playAgain, name})
  end

  def chatMessage(msg, name) do
    GenServer.call(reg(name), {:chatMessage, msg, name})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:play, name, board, boardIndPlayed, rackIndPlayed}, _from, game) do
    game = Scrabble.Game.play(game, board, boardIndPlayed, rackIndPlayed)
    Scrabble.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:swap, name, currentRackIndex}, _from, game) do
    game = Scrabble.Game.swap(game, currentRackIndex)
    Scrabble.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:pass, name}, _from, game) do
    game = Scrabble.Game.pass(game)
    Scrabble.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:forfeit, name}, _from, game) do
    game = Scrabble.Game.forfeit(game)
    Scrabble.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:playAgain, name}, _from, game) do
    game = Scrabble.Game.playAgain(game)
    Scrabble.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:chatMessage, msg, name}, _from, game) do
    game = Map.put(game, :chatMessage, msg)
    Scrabble.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:peek, _name}, _form, game) do
    {:reply, game, game}
  end


end
