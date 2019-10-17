defmodule Scrabble.Game do

	alias Scrabble.Grid
	alias Scrabble.Tiles

	# State:
	# board: Key {x,y} -> {letter, bonus}
	##  x, y are the coordinates in the grid
	## 	letter is the letter placed on that spot
	##  bonus is the special places on the grid where you get extra points
	# tiles: Key {letter, points} -> remaining count
	# rack1, rack2, score1, score2, lastScore1, lastScore2
	# colorList

	def new do
		grid = Grid.getNewGrid()
		clrLst = Grid.getColorList(grid)
		tileList = Tiles.generateTileList()
		{tileList, player1Rack} = Tiles.getTiles(tileList, 7)
		{tileList, player2Rack} = Tiles.getTiles(tileList, 7)

		%{
			board: grid,
			tiles: tileList,
			rack1: player1Rack,
			rack2: player2Rack,

			colorList: clrLst, # for client view, computed once per game
		}
	end

	# restricted client view
	# board will be a list [0-224] converted from (x,y) grid maintained on the
	# server side
	def client_view(game) do
		message = "Hello"
		%{
			board: Grid.getClientBoard(game.board),
			color: game.colorList,
			rack1: game.rack1,
			rack2: game.rack2, # TODO cant send both racks to one client
		}
	end

	# Todo - Delete method and replace with something appr
	def guess(game, letter) do
		true
	end


end
