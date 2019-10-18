defmodule DictionaryApi do
  use HTTPoison.Base
  def check_word(word) do
    url = "https://dictionaryapi.com/api/v3/references/collegiate/json/" <> word <> "?key=eefa30f1-c7f2-44e4-a14e-4d48da208517"
    response = HTTPoison.get!(url)
    req = Poison.decode!(response.body)

    if req == [] do
      false
    end

    [head | tail] = req
    if is_map(head) do
      true
    end

    false
  end

  # Todo Yijia
  # function that takes a list of words to check_word
  # if any word is not correct stops checking and returns the [incorrect word]
  # return empty list if all words are correct

  
end
