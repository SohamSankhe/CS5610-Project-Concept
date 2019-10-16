defmodule Scrabble.Game do
	
	def new do
		%{
			msg: "Hello",
		}
	end
	
	# restricted view
	def client_view(game) do
		message = "Hello"
		%{
			msg: message
		}
	end
	
	# Todo - Delete method and replace with something appr
	def guess(game, letter) do
		true
	end
	
end
