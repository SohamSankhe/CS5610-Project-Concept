defmodule Scrabble.GameSup do
  use DynamicSupervisor

  # Ref - http://www.ccs.neu.edu/home/ntuck/courses/2019/09/cs5610/notes/09-introducing-otp/

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    {:ok, _} = Registry.start_link(keys: :unique, name: Scrabble.GameReg)
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(spec) do
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
