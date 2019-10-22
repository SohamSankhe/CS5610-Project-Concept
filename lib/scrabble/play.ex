defmodule Scrabble.Play do
  alias Scrabble.Grid
  alias Scrabble.ValidatePlay
  alias Scrabble.Words

  def processPlay(game, board, boardIndPlayed, rackIndPlayed) do
    # validate input - ?

		# convert client's single index input values to x,y coord system
    updatedBoard = convertGridCoords(board)
    brdIndexes = Enum.map(boardIndPlayed, fn x -> convertToXY(getInt(x)) end)
    {valStatus, valMsg} = ValidatePlay.isPlayValid(game, updatedBoard, brdIndexes)

    words = []
    if valStatus == :ok do
      # if words are correct, add to Game
      # else add incorrect words to 'words' list
      # in below cond -> case 'words' length
      words = Words.findWords(updatedBoard, brdIndexes)
    end

    cond do
      # case for invalid placement
      valStatus != :ok ->
        game = Map.put(game, :message, valMsg)
        game
      # case for incorrect words - reset play and send message
      # case for correct words - call fn that calc score and returns game
      true ->
        game = Map.put(game, :message, "")
        game = Map.put(game, :board, updatedBoard)
        game
    end

		# find words
		# check words
		# calculate score
		# refill rack
		# send back
  end


  # convert clients single index grid in x,y coord system
  def convertGridCoords(board) do
    indexedBoard = Enum.with_index(board)
    Enum.reduce(indexedBoard, %{}, fn {value, index}, acc ->
        {xCoord, yCoord} = convertToXY(index)
        bonusVal = Grid.getBonus(xCoord, yCoord)
        Map.put(acc, {xCoord, yCoord}, [letter: value, bonus: bonusVal])
      end)
  end

  # x = num % 15 and y = num / 15
  def convertToXY(ind) do
    mod = rem(ind, 15)
    xCoord = mod
    yCoord = div((ind - mod),15)
    #{xCoord, yCoord}
    {yCoord, xCoord}
  end


  def getInt(str) do
    {intVal, ""} = Integer.parse(str)
    intVal
  end

  # find words created/updated
  def findWords(board, boardIndPlayed) do

  end




end
