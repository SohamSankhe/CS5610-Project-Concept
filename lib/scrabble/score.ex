defmodule Scrabble.Score do
  alias Scrabble.Tiles
  alias Scrabble.Words

  def calculateScore(game, board, boardIndPlayed, words) do
    score = Enum.reduce(words, 0, fn x, acc ->
      acc + calculateScoreForWord(board, x, boardIndPlayed) end)
  end

  def calculateScoreForWord(board, word, boardIndPlayed) do
    # add up score for individual letters
    score = Enum.reduce(word, 0, fn {x,y}, acc ->
        acc + calculateScoreForLetter(x,y,board, boardIndPlayed)
      end)

    # check for bonus
    newScore = Enum.reduce(word, score, fn {x,y}, acc ->
        cords = {x,y}
        %{^cords => val} = board
        bon = val[:bonus]
        # bonus applies only when premium tile is newly played
        if Enum.member?(boardIndPlayed, cords) do
          cond do
            bon == "w3" -> score = score * 3
            bon == "w2" -> score = score * 2
            true -> score
          end
        end
      end)

      newScore
  end

  def calculateScoreForLetter(x,y, board, boardIndPlayed) do
    score = 0
    letter = Words.getLetterForCord(x,y,board)
    score = score + Tiles.getPointsForLetter(letter)

    # check if bonus and apply bonus
    cords = {x,y}
    %{^cords => val} = board
    bon = val[:bonus]

    # bonus applies only if the premium tile was newly played
    if Enum.member?(boardIndPlayed, cords) do
      cond do
        bon == "l3" -> score = score * 3
        bon == "l2" -> score = score * 2
        true -> score
      end
    end

    IO.puts("Letter score")
    IO.puts(val[:letter])
    IO.puts(val[:bonus])
    IO.puts(score)
    score
  end
end
