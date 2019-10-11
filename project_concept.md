# Project Concept for Generic Scrabble

#### Authors:  Soham Sankhe, Yijia Hao
&nbsp;

**What game are you going to build?**

Our team plans to build a generic two-player Scrabble Game. Similar to the 
physical Scrabble board game, our online scrabble game also includes a 15*15 
scrabble board, two racks and a bag of 100 letter tiles. The tiles have a score 
depending on the frequency of its usage in words. 
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

The grid has some places in special colors. These are used to double or triple 
the score of the word put on the colored place. After each turn, both the 
players can see the updated scrabble board. A player's rack is not visible to 
the other player. The total score at each step will be recorded and shown on 
the screen simultaneously. The correct words played in the rounds will also be 
displayed on the screen.


### Is the game well specified?

The game is well specified. First, each player will be randomly given 7 tiles. 
The first player needs to put the word at the center of the board. 
Then, it turns to the second player. The second player can either play a word 
based on the current board, choose to exchange a tile from his rack or pass the 
round. Words can be played either in the horizontal or the vertical direction. 
Each word put on the board after the first turn must add to atleast one other 
word already on the board. The rack gets refilled after the player takes some 
pieces out of it, so each player should always have 7 tiles in their rack. 
If any player uses all of the 7 tiles in one round, he/she will get extra 50 
points. 

A player wins if the below conditions are satisfied:
* Other player gives up
    OR
* Has a higher score after all the replacement tiles and the ones in the 
player's rack are used up
The winner with his/her total score shows up on the screen.


#### Is there any game functionality that you’d like to include but may need to cut 
if you run out of time? ####

We would like to cut back on the blank tile feature if we run out of time. 
A blank tile can be converted into any letter tile to suit creating a word.
To implement this feature we would have create another UI feature to prompt the 
user asking which letter he/she wants to use as the blank tile. 
We also hope to include the functionality of deciding who goes first. There 
might be several ways to decide who goes first. The first thought is to draw 
a die, and the side with larger number goes first. The second thought is to 
assign each of the players one tile at the beginning, and whoever gets the 
letter closest to "A" goes first. 



### What challenges do you expect to encounter?

The first challenge for us is to find a way to verify the correctness of the 
words that are being played. 
When a player creates a word, he/she might add to multiple words already on 
the board. In such a case, we should be able to detect all the words that have 
changed and the correctness of these words has to be checked. 
In case of incorrect words, the player has to be shown which word/s is/are 
incorrect among the ones that were created/updated.
To check for correctness we will be using a dictionary API. 
The second challenge is synchronization since we need to update our board, rack 
and score by each step. The third challenge might be the user interface update. 
Once we refill the rack, we may need a dynamic change on the tiles. We will be 
working on these challenges in the coming days.
