// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import $ from "jquery";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"
import scrabble_init from "./genericScrabble";
import index_init from "./index"

// Ref: http://www.ccs.neu.edu/home/ntuck/courses/2019/09/cs5610/notes/05-react/notes.html
function start()
{
	let root = document.getElementById('index_root'); //React root for index page
	if (root)
	{
		let channel = socket.channel("index:" + window.gameName, {});  // The index channel is for index page, which enables user to choose a player1/player2, and create a game
		index_init(root, channel);
	}
    else{
		root = document.getElementById('root'); // React root for game page
		if (root)
		{
			let channel = socket.channel("games:" + window.gameName, {});
			scrabble_init(root, channel);
		}
	}

}

$(start);
