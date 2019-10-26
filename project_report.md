# Generic Scrabble

#### Authors: Soham Sankhe, Yijia Hao

## Introduction and Game Description

We have implemented a 2-player generic scrabble game.
The game comes with a scrabble board, a rack of letters for each player and a 
set of tiles from which letters are drawn to refill the player's rack.
A total of 100 tiles are available in the game. Each rack contains 7 letters.
The players take turns to put a word on the board using the letters in their 
racks. Each time a player forms a word on the board, the letters used are 
replenished from the tile set. Assignment of letters to the players is random.
Each letter tile contains a score. The score a tile has depends on the frequency
of the letter's usage in English language.
A rare letter like Q or Z carries a high score which in this case is 10 points.
Commonly used letters like the vowels carry lower scores. 1 point in this case.

The points and distribution of the tiles is as below:
* 1 point: E ×12, A ×9, I ×9, O ×8, N ×6, R ×6, T ×6, L ×4, S ×4, U ×4
* 2 points: D ×4, G ×3
* 3 points: B ×2, C ×2, M ×2, P ×2
* 4 points: F ×2, H ×2, V ×2, W ×2, Y ×2
* 5 points: K ×1
* 8 points: J ×1, X ×1
* 10 points: Q ×1, Z ×1
* 2 blank tiles (scoring 0 points)

[Source](https://en.wikipedia.org/wiki/Scrabble_letter_distributions#English)

When a word is formed on the board, the score for each letter is added up to get
a total score for the player's turn.
Also, the scrabble board contains premium tiles which allows the players to get 
extra score. The premium tiles available are as below:
* Word * 2 - A word placed having a letter on this tile multiplies the word's 
score by 2
* Word * 3 - A word placed having a letter on this tile multiplies the word's 
score by 3
* Letter * 2 - The letter placed on this tile multiplies the letter's score by 2
* Letter * 3 - The letter placed on this tile multiplies the letter's score by 3

The players cannot arbitrarily place words on the board.
The rules for a valid word placement are as below:
- The words can be placed in either the horizontal or the vertical direction
- Each letter should be consecutively placed
- The first word should be placed at the center of the table
- Subsequent words placed should be contiguous to existing words. That is you 
cannot have floating words.

So, every word placed after the first word should update atleast one other word.
If players update multiple words in their turns, they get points for each of the
updated words. However, during the score calculation, the premium tiles apply 
only to the words that are updated in the current round. 
Therefore, the objective for the players is to get the maximum score by playing 
longer words containing letters which carry more points and placing it in such a
way that it updates multiple words.

Player turns:
During their turns, the players may chose to do one of the below:
- Play a word
- Pass their turn
- Swap a tile from their rack for a random tile from the tile set
- Forfeit the game

The game ends when all the tiles in the tile set are used up and a player plays 
all the remaining tiles in his/her rack. 
In this event, the player with a higher score wins.
A player may also forfeit a game midway causing the other player to win.

## UI Design

Multiple game tables are supported. On the home page or the index page, a user 
can see the list of games that are currently available or are being played.
The user also has an option of creating a new game. Since scrabble is a 2 player
game, the user can join a game as player 1 or player 2.
The index page consists of a heading that displays 'Generic Scrabble', a form 
that accepts a game name as input from the user, a table that displays the 
created games and links to join the games as player 1 or player 2.
A user is redirected to the game page on joining a game.
The game page has a heading that displays the game name and the player name.
The player's turn in the current round is mentioned below the heading.
A flex container is used to display a 15 * 15 scrabble board that occupies the 
left half of the page.
The premium tiles on the board are indicated with separate colors. 
The color code is as below:

* Word * 2 - Green  
* Word * 3 - Red
* Letter * 2 - Blue
* Letter * 3 - Yellow

The scrabble board is nothing but a table containing buttons. The player's rack 
is displayed on the right half of the page. The tiles on the rack change color 
based on click events to indicate which tile is being selected or which tiles 
are already placed on the board.

Player action buttons are placed below the rack.
The buttons and their descriptions are as below:
* Play - Click after placing a word on the board to submit your turn
* Clear - Clears any letters placed on the board in the current turn
* Swap - Swaps the selected letter in the rack for a random letter from the tile
set
* Pass - Click to pass on your turn to the other player
* Give up! - Forfeit the game

The scores are displayed below the action buttons. 
Each player's total score and their score in the previous round is displayed.
The list of words created or updated by a player in their previous turn is 
displayed below.
A chat box occupies the rest of the space on the right hand side of the page.
The chat box contains a text box which displays the ongoing chat, an input text 
area where a player writes their chat messages and a submit button to post the 
chat message.

## UI to Server Protocol

The state maintained at the client side contains the below data:
* board: A list of length 225 which contains the letters placed on the board.
* color: A list of length 225 which is used to display the premium tiles on the 
board.
* rack: A list of length 7 containing the letters in the current player's rack.
* currentRackIndex: Index of the rack button currently selected.
* rackIndexesPlayed: Indexes of the rack that are currently placed on the board
* boardIndexesPlayed: Indexes of the board wheree letters played in the current 
turn are placed
* message: A string to display server side messages to the players. 
* words: List of correct words played in the previous round
* score1, score2, lastScore1, lastScore1: Player scores
* whosTurn: Player's turn
* isActive: True if the game is active
* chatMessage

The data maintained as state on the server side is the similar with below 
exceptions:
* Rack1 and Rack2 are maintained in place of the single 'rack' pushed to the 
client
* A tile set containing all the tiles maintained. The client has no use for this

A server call is made only for 'play', 'swap', 'pass', 'give up' action buttons 
and the 'submit' chat button.
All other buttons are handled at the client-side itself.

### Protocols:

#### Play:
The client provides the server with the updated board, board indexes and rack 
indexes played in the current round.
The server validates the word placement based on the aforementioned rules.
If the placement is invalid, all the changes made in the current round are 
discarded and an appropriate error message is displayed to the user.
If the placement is valid, the words created or updated are checked for 
correctness using a dictionary API.
If any of the words are incorrect, the changes made in the current round are 
discarded and the user is told which words are incorrect.
If the words formed are correct, the score for the turn is calculated, the 
user's rack is refilled and the new words are displayed to the user.

#### Swap:
The current rack index selected by the user for swap is sent server side.
The server adds the selectd letter back to the tile set and replaces it with a 
random letter drawn from the tile set. Player turn is then toggled.

#### Pass:
Simply, the turn of the player is passed on to the other player.

#### Give up!:
The game is ended by setting the isActive flag to false. 
A message is displayed indicating which player has won.
The player with the higher score is the winner.
Setting isActive flag to false has a side-effect of displaying a 'Play Again' 
button to the players.

#### Play Again:
On click, server returns a fresh game state to the client to start a new game.


## Data structures on server

#### Board:
The board on the client is represented by a list of charachters of length 225.
This is to keep the handling of the board simple on the client side.
However, on the server side we need to make a lot of fetches from the board and 
maintaining it as a list would not be efficient.
The board (or grid) on the server side is a map.
It is represented in a more intuitive x,y coordinate form.
The top right corner is {0,0} with the x-axis going horizontally to the right 
and the y-axis going down vertically.
This is done to match the order of rendering of buttons at the client-side.
Key of the map is a tuple of the form {x,y}.
Value of the map is a keyword list of the form 
[letter: "letterPlaced", bonus: "premiumType"]
Thus, our random accesses now have a time complexity of O(1) instead of the 
previous O(n).

#### Tiles:
A tile frequency map is maintained at the server side whose key is the letter 
and value is the number of those letters in the tile set.
This map is a constant and is used only once per game to initialize the tile set
which is a list of letters.
For replenishment of tiles in the rack, the tile set is shuffled and the last 
'n' letters are sliced out to fill the rack. Here 'n' is the number
of tiles required to fill the rack.

#### Points:
For calculation of scores, we need to know how many points a letter is worth.
This is maintained as a constant map.
The server side game state is also maintained as a map.

## Implementation of game rules:

Some of the salient game rule implementations are as below:

#### Find words updated/created on the board:
When a user adds a word to the board, multiple words can be updated.
Approach used to find these words is as below:
xs = Set of x coordinates from the board indexes played  
ys = Set of y coordinates from the board indexes played  
One of these sets has to have just one integer in them as the words can be 
played in either horizontal or vertical direction.  
For each x in xs, get words along the axis into a word set  
For each y in xs, get words along the axis into a word set  
Remove words from the word set that do not contain any board indexes played in 
the current round. Those are among the already existing words.
Whatever remains in the set are words created/updated in the current round.

#### Check correctness of the words played
All the created/updated words are verified using the Webster dictionary API.
Sadly, the API only supports one word at a time and we can not batch the words 
together for one API call words check.
HTTPoison library is used to make the API call.
The returned JSON response is parsed using Poison library.
The response returned for valid words is huge but we noticed that for any valid 
words, the JSON list starts with a map.
It returns an empty list of a list of possible words for an incorrect word.
So, our check for correctness is simply 'is_map(hd(response))'.

#### Play validations:

Rule - First word should be placed in the center:
We simply check if the boardIndPlayed includes {7,7}.

Rule - Words should be horizontally of vertically placed:
xs = Set of x coordinates from the board indexes played<br />
ys = Set of y coordinates from the board indexes played
One of these should have length = 1.

Words should be consecutively placed:
xs = Set of x coordinates from the board indexes played
ys = Set of y coordinates from the board indexes played
If size of xs == 1, 
  Board indexes from {x,min(ys)} ... {x, max(ys)} should have a letter in them.
Else
  Board indexes from {min(xs),y} ... {max(xs),y} should have a letter in them.

Words placed should be contigous:
We get a list of coordinates adjacent to each index in the list of board indexes
played. If atleast one of these coordinates has a letter in them which is not a 
part of indexes played in the current round, we know that they are joined to 
aleast one other word.


## Challenges and Solutions

Since the server is written in a functional programming language, most of the 
challenges were regarding data mutations and their side-effects. 
The same applies for the react code as well.
This caused an increase in the time required to finish the project.
Online tutorials were helpful in understanding these technologies better.
Most of the code intially written has a recursive function with a context 
parameter to achieve anything that required looping. The Enum library was more 
effectively used later on as I got comfortable with its usage.
Other challenges faced were phoenix configuration related.
Getting concurrency and multi-threading support in phoenix required a bit of 
trial-and-error approach. To start off, we created a one player scrabble game 
and then struggled to convert it into a two player game. The class notes and 
phoenix documentation helped us through it.








