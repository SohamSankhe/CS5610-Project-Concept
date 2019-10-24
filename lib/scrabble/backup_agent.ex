defmodule Scrabble.BackupAgent do
  use Agent

  # Ref: Hangman example done in class

  def start_link(_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(name, val) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, val)
    end
  end

  def get(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end

  def get_keys do
    Agent.get __MODULE__, fn state ->
          Map.keys(state)
    end
  end
end
