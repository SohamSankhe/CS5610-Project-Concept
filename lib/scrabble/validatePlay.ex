defmodule Scrabble.ValidatePlay do

  def isPlayValid(game, board, boardIndPlayed) do

    {status, dir} = isDirectionCorrect(boardIndPlayed)
    cond do
      status == :error -> {:error, dir}
      !isFirstWordCentrallyPlaced(game, boardIndPlayed) ->
          {:error, "First word should be placed in the center"}
      !isWordConsecutivelyPlaced(game, board, boardIndPlayed, dir) ->
          {:error, "Letters should be consecutively placed"}
      !isPlacementValid(game, board, boardIndPlayed, dir) ->
        msg = if (game.score1 == 0 and game.score2 == 0) do
                "Word played must be connected to at least one other word"
              else
                 "Letters should be consecutively placed"
              end
              {:error, msg}
      true -> {:ok, ""}
    end
  end

  # First word should be placed in the center
  def isFirstWordCentrallyPlaced(game, boardIndPlayed) do
    if game.score1 == 0 and game.score2 == 0 do
      if Enum.member?(boardIndPlayed, {7,7}) do
        true
      else
        false
      end
    else
      true
    end
  end

  def isWordConsecutivelyPlaced(game, board, boardIndPlayed, dir) do
    if dir == "ver" do
      {x, _} = hd(boardIndPlayed)
      ySet = Enum.reduce(boardIndPlayed, MapSet.new(), fn {_x,y}, acc ->
                MapSet.put(acc, y)
              end)
      yList = MapSet.to_list(ySet)
      yList = Enum.sort(yList)
      IO.inspect yList
      min = hd(yList)
      max = Enum.at(yList, length(yList)-1)
      lettersToCheck = Enum.reduce(min..max, [], fn y, acc -> acc ++ [{x,y}] end)
      IO.inspect lettersToCheck
      Enum.reduce(lettersToCheck, true, fn {x,y}, acc ->
          acc and isLetter(x,y, board)
        end)
    else
      {_, y} = hd(boardIndPlayed)
      xSet = Enum.reduce(boardIndPlayed, MapSet.new(), fn {x,_}, acc ->
                MapSet.put(acc, x)
              end)
      xList = MapSet.to_list(xSet)
      xList = Enum.sort(xList)
      IO.inspect xList
      min = hd(xList)
      max = Enum.at(xList, length(xList)-1)
      lettersToCheck = Enum.reduce(min..max, [], fn x, acc -> acc ++ [{x,y}] end)
      IO.inspect lettersToCheck
      Enum.reduce(lettersToCheck, true, fn {x,y}, acc ->
          acc and isLetter(x,y, board)
        end)
    end
  end


  def isDirectionCorrect(boardIndPlayed) do
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

  # tests for contiguousness and continousness
  def isPlacementValid(game, board, boardIndPlayed, direction) do
    status = isAdjacent(game, board, boardIndPlayed)
    IO.puts("isAdjacent")
    IO.inspect status
    if status do
      val = isJoinedToExistingWord(game, board, boardIndPlayed)
      IO.puts("is contigous")
      IO.inspect val
      val
    else
      false
    end
  end

  # implicit check for continousness of the word
  def isAdjacent(game, board, boardIndPlayed) do
    flag = Enum.reduce(boardIndPlayed, true, fn {x,y}, acc ->
        if areAdjSpotsBlank(x,y, board) == 0 do
          acc and false
        else
          acc and true
        end
      end)
    flag
  end

  # not so implicit check for contiguousness to other words
  def isJoinedToExistingWord(game, board, boardIndPlayed) do
    if (game.score1 == 0) and (game.score2 == 0) do # 1st round
      true
    else
       val = Enum.find(getAdjCoord(board, boardIndPlayed), 0, fn {xCord, yCord} ->
          if (xCord >= 0) and (xCord <= 14) and (yCord >= 0) and (yCord <= 14) do
            cordKey = {xCord, yCord}
            %{^cordKey => val} = board
            val[:letter] != ""
          end
        end)
        if val == 0 do
          false
        else
          true
        end
    end
  end

  def getAdjCoord(board, boardIndPlayed) do
    adjList = Enum.reduce(boardIndPlayed, [], fn {x,y}, acc ->
        acc ++ getAdjListMinusDiagonals(x,y)
      end)
    withCurrentPlayRemoved = Enum.reduce(adjList, [], fn xy, acc ->
        if Enum.member?(boardIndPlayed, xy) do
          acc
        else
          acc ++ [xy]
        end
      end)
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

  def getAdjListMinusDiagonals(x,y) do
    [{x+1,y},{x-1,y},
     {x,y+1},{x,y-1}]
  end

  def isLetter(xCord,yCord,board) do
    if (xCord >= 0) and (xCord <= 14) and (yCord >= 0) and (yCord <= 14)  do
      cordKey = {xCord, yCord}
      %{^cordKey => val} = board
      val[:letter] != ""
    else
      true
    end
  end

end
