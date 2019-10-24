defmodule Scrabble.Words do

  # return a list of words created/updated due to a play
  # Algo:
  # xs = set of x coordinates from indexes played
  # ys = set of y coordinates from indexes played
  # For each x in xs, get words along the axis into a word set
  # For each y in xs, get words along the axis into a word set
  # For each word in wordSet,
  # If word contains one of the indexes played, it is a word
  # that is created or updated due to the player's turn

  def findWords(board, boardIndPlayed) do

    # get set of x coords and y coords
    xs = Enum.reduce(boardIndPlayed, MapSet.new(), fn {x,_y}, acc ->
              MapSet.put(acc, x)
            end)
    ys = Enum.reduce(boardIndPlayed, MapSet.new(), fn {_x,y}, acc ->
              MapSet.put(acc, y)
            end)

    # get words along each x cord and then y coord
    wordSet = MapSet.new()
    xWordList = unpackList(getWordsAlongAxis(xs, board, "x"))
    yWordList = unpackList(getWordsAlongAxis(ys, board, "y"))

    # filtering out 1 letter words
    xWordList = Enum.reduce(xWordList, [], fn word, acc ->
                  if length(word) > 1 do
                    acc ++ [word]

                  else
                    acc

                  end
                end)

    yWordList = Enum.reduce(yWordList, [], fn word, acc ->
                  if length(word) > 1 do
                    acc ++ [word]
                  else
                    acc

                  end
                end)

    xWordSet = MapSet.new(if xWordList != nil, do: xWordList, else: [])
    yWordSet = MapSet.new(if yWordList != nil, do: yWordList, else: [])

    wordSet = MapSet.union(xWordSet, yWordSet)

    # if word in wordSet contains any from boardIndPlayed, it stays
    brdIndPlayedSet = MapSet.new(boardIndPlayed)
    wordList = Enum.reduce(wordSet, [], fn word, acc ->
      intr = MapSet.intersection(brdIndPlayedSet, MapSet.new(word))
      if MapSet.size(intr) >= 1 do
        acc ++ [word]
      else
        acc
      end
    end)

    IO.puts("Final word list")
    IO.inspect wordList

    wordList
  end

  def getWordsAlongAxis(coordSet, board, axis) do
    if axis == "x" do
      Enum.reduce(coordSet, [], fn x, acc ->
        wordList = getWordsAlongXAxis(board, x, [], [], 0, false)
        acc ++ [wordList]
      end)
    else
      Enum.reduce(coordSet, [], fn y, acc ->
        wordList = getWordsAlongYAxis(board, 0, [], [], y, false)
        acc ++ [wordList]
      end)
    end
  end


  # this is somehow gettng along y axis
  def getWordsAlongXAxis(board, x, wordList, word, y, isWord) do
    if y < 14 do
      letter = getLetterForCord(x, y, board)
      cond do
        (letter == "") and (!isWord) ->
          getWordsAlongXAxis(board, x, wordList, word, y + 1, isWord)
        (letter == "") and (isWord) ->
          newWordList = wordList ++ [word]
          getWordsAlongXAxis(board, x, newWordList, [], y + 1, false)
        (letter != "") and (isWord) ->
          newWord = word ++ [{x,y}]
          getWordsAlongXAxis(board, x, wordList, newWord, y + 1, isWord)
        (letter != "") and (!isWord) ->
          newWord = word ++ [{x,y}]
          getWordsAlongXAxis(board, x, wordList, newWord, y + 1, true)
      end
    else
      wordList
    end
  end

  def getWordsAlongYAxis(board, x, wordList, word, y, isWord) do
    if x < 14 do
      letter = getLetterForCord(x, y, board)
      cond do
        (letter == "") and (!isWord) ->
          getWordsAlongYAxis(board, x + 1, wordList, word, y, isWord)
        (letter == "") and (isWord) ->
          newWordList = wordList ++ [word]
          getWordsAlongYAxis(board, x + 1, newWordList, [], y, false)
        (letter != "") and (isWord) ->
          newWord = word ++ [{x,y}]
          getWordsAlongYAxis(board, x + 1, wordList, newWord, y, isWord)
        (letter != "") and (!isWord) ->
          newWord = word ++ [{x,y}]
          getWordsAlongYAxis(board, x + 1, wordList, newWord, y, true)
      end
    else
      wordList
    end
  end

  # returns {:ok, correctWords}
  #         {:error, incorrectWords}
  def checkWords(board, wordList) do
    # convert word coord list to actual words
    wordsPlayed = convertToActualWord(board, wordList)
    IO.puts("Words played:")
    IO.inspect wordsPlayed

    # verify correctness
    incorrectWords = DictionaryApi.checkWords(wordsPlayed)
    IO.puts("Incorrect words:")
    IO.inspect incorrectWords

    if length(incorrectWords) > 0 do
      {:error, wordsPlayed, incorrectWords}
    else
      {:ok, wordsPlayed, []}
    end
  end


  # https://stackoverflow.com/questions/44613261/elixir-how-to-convert-keyword-list-to-string
  def convertToActualWord(board, wordList) do
    letterList = Enum.map(wordList, fn x -> getLettersForCoordList(x, board) end)
    wordList = Enum.reduce(letterList, [], fn ls, acc ->
        acc ++ [Enum.reduce(ls, "", fn y, acc -> "#{acc}#{y}" end)]
      end)
  end


  def getLettersForCoordList(lst, board) do
    Enum.reduce(lst, [], fn {x,y}, acc ->
        acc ++ [getLetterForCord(x,y,board)]
    end)
  end

  def getLetterForCord(x, y, board) do
    cord = {x, y}
    %{^cord => val} = board
    val[:letter]
  end

  def unpackList(lst) do
    newLst = Enum.reduce(lst, [], fn x, acc ->
      lst = Enum.reduce(x, [], fn y, acc1 ->
        acc1 ++ [y]
      end)
      acc ++ lst
    end)
  end


end
