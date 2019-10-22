defmodule Scrabble.Game do

	alias Scrabble.Grid
	alias Scrabble.Tiles
	alias Scrabble.Play

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
			message: "",
			words: [],
			score1: 0,
			score2: 0,
			lastScore1: 0,
			lastScore2: 0,
			# Below added just for consistency betw server & client state (needed?)
			# currentRackIndex: -1,
			# indexesPlayed: [],
		}
	end

	# restricted client view
	# board will be a list [0-224] converted from (x,y) grid maintained on the
	# server side
	def client_view(game) do
		%{
			board: Grid.getClientBoard(game.board),
			color: game.colorList,
			rack1: game.rack1,
			rack2: game.rack2, # TODO cant send both racks to one client

			# Below added just for consistency betw server & client state (needed?)
			currentRackIndex: -1,
      rackIndPlayed: [],
      boardIndPlayed: [],
			message: game.message,
			words: game.words,
			score1: game.score1,
			score2: game.score2,
			lastScore1: game.lastScore1,
			lastScore2: game.lastScore2,
		}
	end

	def play(game, board, boardIndPlayed, rackIndPlayed) do
		IO.inspect game # game.board is the original board
		IO.inspect board # updated board
		IO.inspect boardIndPlayed

		newGame = Play.processPlay(game, board, boardIndPlayed, rackIndPlayed)
		IO.puts("New game")
		IO.inspect(newGame)
		newGame
		#game
	end

	# Todo - Delete method and replace with something appr
	def guess(game, letter) do
		true
	end


end
