defmodule Scrabble.Game do

	alias Scrabble.Grid
	alias Scrabble.Tiles
	alias Scrabble.Play

	# Reference for new and client_view - Hangman example done in class

	# Server side state:
	# grid is the scrabble board: %{{x,y} => [letter: letterPlaced, bonus: premium tile]}
	# rack1, rack2 - racks for player 1 and player 2
	# tiles - List of letters that are used to fill rack
	# words - correct words played in the previous round

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
			whosturn: "player1",
			currentRackIndex: -1,
			isActive: true,
			chatMessage: [],
		}
	end

	# restricted client view
	# board will be a list [0-224] converted from (x,y) grid maintained on the
	# server side
	def client_view(game, player) do
	    client_game =
		%{
			board: Grid.getClientBoard(game.board),
			color: game.colorList,
      rack: [],
			currentRackIndex: -1,
			rackIndPlayed: [],
      boardIndPlayed: [],
			message: game.message,
			words: game.words,
			score1: game.score1,
			score2: game.score2,
			lastScore1: game.lastScore1,
			lastScore2: game.lastScore2,
			whosturn: game.whosturn,
			isActive: game.isActive,
			chatMessage: Enum.join(game.chatMessage)
		}
        |> Map.put(:rack, check_player(game, player))
	end

	def broadcast_view(game) do
		client_game =
				%{
					board: Grid.getClientBoard(game.board),
					color: game.colorList,
					rack: [],
					currentRackIndex: -1,
					rackIndPlayed: [],
					boardIndPlayed: [],
					message: game.message,
					words: game.words,
					score1: game.score1,
					score2: game.score2,
					lastScore1: game.lastScore1,
					lastScore2: game.lastScore2,
					whosturn: game.whosturn,
					isActive: game.isActive,
					chatMessage: Enum.join(game.chatMessage)
				}
	end

	def play(game, board, boardIndPlayed, rackIndPlayed) do
		newGame = Play.processPlay(game, board, boardIndPlayed, rackIndPlayed)
	end

	def swap(game, currentRackIndex) do
		newGame = Play.processSwap(game, currentRackIndex)
	end

	def pass(game) do
		newGame = Play.processPass(game)
	end

	def forfeit(game) do
		newGame = Play.processForfeit(game)
	end

	def playAgain(game) do
		newGame = new()
		newGame
	end

  def check_player(game, player) do
    if player == "player1" do
      rack = game.rack1
    else
      rack = game.rack2
    end
  end

end
