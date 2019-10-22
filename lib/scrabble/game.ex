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

			# Below added just for consistency betw server & client state (needed?)
			# currentRackIndex: -1,
			# indexesPlayed: [],
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
            rack: game.rack,

			# Below added just for consistency betw server & client state (needed?)
			currentRackIndex: -1,
            rackIndPlayed: [],
            boardIndPlayed: [],
		}
	end

	def play(game, board, boardIndPlayed, rackIndPlayed) do
		# validate input
		# convert board to x,y coord system
		# validate if play is either horizontal or vertical
		# find words
		# check words
		# calculate score
		# refill rack
		# send back
		game
	end

	# Todo - Delete method and replace with something appr
	def guess(game, letter) do
		true
	end

    def check_player(player, game) do
      if player == "player1" do
        rack = game.rack1
      else
        rack = game.rack2
      end
    end

end
