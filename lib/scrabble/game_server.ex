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
    |> Map.delete(:rack1)
    |> Map.delete(:rack2)
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end


  def init(game) do
    {:ok, game}
  end

end