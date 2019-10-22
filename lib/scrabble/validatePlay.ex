defmodule Scrabble.ValidatePlay do

  def isPlayValid(game, board, boardIndPlayed) do
    {status, dir} = isDirectionCorrect(boardIndPlayed)
    cond do
      status == :error -> {:error, dir}
      !isPlacementValid(game, board, boardIndPlayed, dir) ->
        {:error, "Word played must be connected to atleast one other word"}
      # consecutive condition
      true -> {:ok, ""}
    end

  end


  def isDirectionCorrect(boardIndPlayed) do
    # what to do for only 1 word played
    xSet = Enum.reduce(boardIndPlayed, MapSet.new(), fn {x,_y}, acc ->
              MapSet.put(acc, x)
            end)
    ySet = Enum.reduce(boardIndPlayed, MapSet.new(), fn {_x,y}, acc ->
              MapSet.put(acc, y)
            end)
    cond do
      MapSet.size(xSet) == 1 -> {:ok, "ver"}
      MapSet.size(ySet) == 1 -> {:ok, "hor"}
      true -> {:error, "Words should be in either horizontal or vertical direction"}
    end
  end


  def isPlacementValid(game, board, boardIndPlayed, direction) do
    # TODO if both scores = 0 - first attempt, only check continous prop
    status = isAdjacent(board, boardIndPlayed)
    IO.puts("Is adjacent")
    IO.puts(status)
    if status do
      true
    else
      false
    end
  end

  # TODO check if consecutive
  # - if horizontal - get leftmost and rightmost played
  # - if vertical - get topmost and bottommost played
  # - check if cood in between are filled

  def isAdjacent(board, boardIndPlayed) do
    flag = Enum.reduce(boardIndPlayed, true, fn {x,y}, acc ->
        if areAdjSpotsBlank(x,y, board) == 0 do
          acc and false
        else
          acc and true
        end
      end)
    flag
  end

  # returns 0 if all adjacent are blank
  def areAdjSpotsBlank(x,y, board) do
    # get adjacent board cord
    adjList = getAdjacencyList(x,y)
    # check if any of those have a letter in them
    Enum.find(adjList, 0, fn {xCord, yCord} ->
        if (xCord >= 0) and (xCord <= 14) and (yCord >= 0) and (yCord <= 14)  do
          cordKey = {xCord, yCord}
          %{^cordKey => val} = board
          val[:letter] != ""
        end
      end)
  end

  def getAdjacencyList(x,y) do
    [{x+1,y},{x-1,y},
     {x,y+1},{x,y-1},
     {x+1,y+1},{x+1,y-1},
     {x-1,y+1},{x-1,y-1}]
  end

end
