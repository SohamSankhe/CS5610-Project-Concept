defmodule DictionaryApi do
  use HTTPoison.Base

  # References for the api:
  # https://dictionaryapi.com/account/example?key=eefa30f1-c7f2-44e4-a14e-4d48da208517

  # Elixir http request:
  # https://medium.com/@a4word/oh-the-api-clients-youll-build-in-elixir-f9140e2acfb6
  # https://stackoverflow.com/questions/46633620/make-http-request-with-elixir-and-phoenix

  # Poison:
  # https://github.com/edgurgel/httpoison

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
