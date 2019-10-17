defmodule DictionaryApi do
  use HTTPoison.Base
  def check_word(word) do
    url = "https://dictionaryapi.com/api/v3/references/collegiate/json/" <> word <> "?key=eefa30f1-c7f2-44e4-a14e-4d48da208517"
    response = HTTPoison.get!(url)
    req = Poison.decode!(response.body)
    if req == [] do
      return false 
    [head | tail] = req
    if is_map(head) do
      return true
    end
    return false
  end
end
























