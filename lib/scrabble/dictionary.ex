defmodule DictionaryApi do
  use HTTPoison.Base
  def check_word(word) do
    url = "https://dictionaryapi.com/api/v3/references/collegiate/json/" <> word <> "?key=eefa30f1-c7f2-44e4-a14e-4d48da208517"
    response = HTTPoison.get!(url)
    req = Poison.decode!(response.body)

    cond do
      req == [] -> false
      is_map(hd(req)) -> true
      true -> false
    end

  end

  # returns list if incorrect words, if any
  def checkWords(wordList) do
    incorrectWords = Enum.reduce(wordList, [], fn word, acc ->
        if !check_word(word) do
          acc ++ [word]
        end
    end)

    if incorrectWords == nil do
      []
    else
      incorrectWords
    end
  end
  
end
