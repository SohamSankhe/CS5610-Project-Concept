defmodule Scrabble.Grid do

  # constant lists for each bonus type containing coords where you get bonus
  # word * 3
  @w3 [{0,0},{7,0},{14,0},{0,7},{14,7},{0,14},{7,14},{14,14}]
  # word * 2
  @w2 [{3,0},{11,0},
       {6,2},{8,2},
       {0,3},{7,3},{14,3},
       {2,6},{6,6},{8,6},{12,6},
       {3,7},{11,7},
       {2,8},{6,8},{8,8},{12,8},
       {0,11},{7,11},{14,11},
       {6,12},{8,12},
       {3,14},{11,14}]
  # letter * 2
  @l3 [{1,5},{1,9},
       {5,1},{5,5},{5,9},{5,13},
       {9,1},{9,5},{9,9},{9,13},
       {13,5},{13,9}]
  # letter * 3
  @l2 [{1,1},{2,2},{3,3},{4,4},{7,7},{10,10},{11,11},{12,12},{13,13},
       {1,13},{2,12},{3,11},{4,10},{10,4},{11,3},{12,2},{13,1}]

  # color constants for bonus spaces
  @w3Color "red"
  @w2Color "green"
  @l3Color "yellow"
  @l2Color "blue"

  # Ref for colors: http://www.2letterwords.com/Comparing_Boards.html

  # Checks if this is a special grid place
  def getBonus(xCoord, yCoord) do
    cond do
      Enum.member?(@w3, {xCoord, yCoord}) -> "w3"
      Enum.member?(@l3, {xCoord, yCoord}) -> "l3"
      Enum.member?(@w2, {xCoord, yCoord}) -> "w2"
      Enum.member?(@l2, {xCoord, yCoord}) -> "l2"
      true -> ""
    end
  end

  # returns a new 15*15 grid
  # grid is 0-indexed
  # starts from bottom left corner with x axis going right
  # and y axis going up
  def getNewGrid() do
    grid = xCoordLoop(%{}, 0)
  end

  # loop for xcoord in grid > 0 - 14
  def xCoordLoop(grid, xCoord) do
    cond do
      xCoord == 15 -> grid
      true -> xCoordLoop(yCoordLoop(grid, xCoord, 0),xCoord+1)
    end
  end

  # loop for ycoord in grid > 0 - 14 for the given xCoord
  def yCoordLoop(grid, xCoord, yCoord) do
    cond do
      yCoord == 15 -> grid
      true ->
        bonus = getBonus(xCoord, yCoord)
        newGrid = Map.put(grid, {xCoord, yCoord}, [letter: "", bonus: bonus])
        yCoordLoop(newGrid, xCoord, yCoord + 1)
    end
  end

  # returns a [0-244] list of letters for client side display
  def getClientBoard(grid) do
    xCoordLst(grid, [], 0, "brd")
  end

  # returns a [0-244] color list for client side display
  def getColorList(grid) do
    xCoordLst(grid, [], 0, "clr")
  end

  # generic x loop for grid
  def xCoordLst(grid, lst, xCoord, task) do
    cond do
      xCoord == 15 -> lst
      true ->
        cond do
          task == "clr" ->
            xCoordLst(grid, yCoordClr(grid, lst, xCoord, 0), xCoord + 1, task)
          task == "brd" ->
            xCoordLst(grid, yCoordBrd(grid, lst, xCoord, 0), xCoord + 1, task)
        end
    end
  end

  # y loop for grid
  # pattern matches x,y in the grid and decides which color to put in list
  def yCoordClr(grid, clrLst, xCoord, yCoord) do
    cond do
      yCoord == 15 -> clrLst
      true ->
        key = {xCoord, yCoord}
        %{^key => val} = grid
        bonusKey = val[:bonus]
        cond do
            bonusKey == "w3" ->
              yCoordClr(grid, clrLst ++ [@w3Color], xCoord, yCoord + 1)
            bonusKey == "w2" ->
              yCoordClr(grid, clrLst ++ [@w2Color], xCoord, yCoord + 1)
            bonusKey == "l3" ->
              yCoordClr(grid, clrLst ++ [@l3Color], xCoord, yCoord + 1)
            bonusKey == "l2" ->
              yCoordClr(grid, clrLst ++ [@l2Color], xCoord, yCoord + 1)
            true ->
              yCoordClr(grid, clrLst ++ ["white"], xCoord, yCoord + 1)
        end
    end
  end

  # y loop for grid
  # pattern matches x,y in the grid and decides which letter to put in list
  def yCoordBrd(grid, brdLst, xCoord, yCoord) do
    cond do
      yCoord == 15 -> brdLst
      true ->
        key = {xCoord, yCoord}
        %{^key => val} = grid
        letter = val[:letter]
        yCoordBrd(grid, brdLst ++ [letter], xCoord, yCoord + 1)
    end
  end

  # debug methods
  def getClrLst() do
    getColorList(getNewGrid())
  end

  def getBrdLst() do
    getClientBoard(getNewGrid())
  end

end
