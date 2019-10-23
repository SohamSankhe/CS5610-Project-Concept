defmodule Scrabble.Play do
  alias Scrabble.Grid
  alias Scrabble.ValidatePlay
  alias Scrabble.Words
  alias Scrabble.Tiles
  alias Scrabble.Score

  def processPlay(game, board, boardIndPlayed, rackIndPlayed) do
    # 'board' arg contains board with the latest play on it

	# convert client's single index input values to x,y coord system
    updatedBoard = convertGridCoords(board)
    brdIndexes = Enum.map(boardIndPlayed, fn x -> convertToXY(getInt(x)) end)
    # Validate input
    {valStatus, valMsg} = ValidatePlay.isPlayValid(game, updatedBoard, brdIndexes)


    if valStatus == :ok do
    # Identify words updated/created
      wordCoords = Words.findWords(updatedBoard, brdIndexes)

      # check correctness of words
      {_, words, incorrectWords} = Words.checkWords(updatedBoard, wordCoords)
      cond do
        length(incorrectWords) > 0 ->
          handleIncorrectWordPlay(game, incorrectWords)
        true ->
          handleCorrectWordPlay(game, updatedBoard, rackIndPlayed, brdIndexes, words, wordCoords)
      end
    else
      game = Map.put(game, :message, valMsg)
      game
    end
  end

  def handleCorrectWordPlay(game, updatedBoard, rackIndPlayed, boardIndPlayed,
        words, wordCoords) do

    # score game updatedboard boardindplayed wordCoords
    #score = Score.calculateScore(game, updatedBoard, boardIndPlayed, wordCoords)
    score = 0

    # TODO Yijia - code to decide which rack and which score to be updated based
    # on player
    {remainingTiles, newRack} = updateRack(game, game.rack1, rackIndPlayed)

    game = Map.put(game, :rack1, newRack)
    game = Map.put(game, :tiles, remainingTiles)
    game = Map.put(game, :board, updatedBoard)
    game = Map.put(game, :words, words)
    game = Map.put(game, :message, "")
    game = Map.put(game, :lastScore1, score)
    game = Map.put(game, :score1, game.score1 + score)
    game
  end

  def handleIncorrectWordPlay(game, incorrectWords) do
    incorrectWordStr = Enum.reduce(incorrectWords, "", fn y, acc -> "#{acc} #{y}" end)
    msg = "Incorret words: " <> incorrectWordStr
    game = Map.put(game, :message, msg)
    game
  end

  # a player's rack and the indexes of tiles he has used
  # replace those tiles in the rack from tiles.ex
  def updateRack(game, rack, rackIndPlayed) do
    rackIndPlayedInt = Enum.reduce(rackIndPlayed, [], fn x, acc ->
      acc ++ [getInt(x)] end)
    # remove played indexes
    rackWithIndexes = Enum.with_index(rack)
    updatedRack = Enum.reduce(rackWithIndexes, [], fn {val, index}, acc ->
      if !Enum.member?(rackIndPlayedInt, index) do
          acc ++ [val]
      else
          acc
      end
    end)

    tilesReq = 7 - length(updatedRack)
    {tileList, newRack} = Tiles.getTiles(game.tiles, tilesReq)
    {tileList, newRack ++ updatedRack}
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

end