import React from 'react';
import ReactDOM from 'react-dom';

export default function index_init(root, channel) {
    ReactDOM.render(<GameIndex channel = {channel} />, root);
}

class GameIndex extends React.Component {
    constructor(props) {
        super(props);
        this.channel = props.channel;
        this.state = {
            game_name: []    //This state save the list of game names created
        };

        this.channel.join()
            .receive("ok", this.onJoin.bind(this))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });

        this.channel.on("update", this.onJoin.bind(this));
    }

    onJoin(view) {          //Get the existed game through channel and show the game on the index page
        console.log("new view", view);
        this.setState(view);
    }

    add_game(ev) {          //As clicking the create button, we add a new game. Game name is the one came from the input box.
        let game_name = this.state.game_name;
        let name = document.getElementById("name_input").value; //Get game name from input box
        let letterNumber = /^[0-9a-zA-Z]+$/;     //constrain of the input game_name by regularization
        if (name.match(letterNumber) && !game_name.includes(name)){         //Require the user to input a valid gamename
            game_name.push(name);
            this.setState({"game_name": game_name});        //update the list of game_name
            this.channel.push("add", {"name": name})                //Save the created game into BackupAgent
                .receive("ok", resp => {console.log(resp)});
        }
        else{
            alert("The name has been used or the name is invalid.")
        }
    }


    render() {
        return (
            <div>
                <form>
                {/*Game Name: <input id = "name_input" type="text"></input>*/}
                {/*<button onClick={this.add_game.bind(this)}>Create</button><br></br>*/}
                {/*<p>The game name should be alphanumeric</p>*/}
                <label>
                    Want to create a new game? (Alphanumeric required)</label><br></br>
                    <label>
                        Input Game Name:
                        <input id = "name_input" type="text"/>
                    </label>
                    <br></br>
                    <button onClick={this.add_game.bind(this)}>Create</button>
                <GameList game_name = {this.state.game_name}/>
                </form>
            </div>
        );
    }
}

function GameList(params){
    let game_name = params.game_name;
    // Choose to join as player1 or player2 by click the link. Player1 and player2 will be passed to game page and saved in window.player. Window.player can control which rack is shown on the game page by passing it into game channel.
    let listItems = game_name.map((name)=> <tr><td>{name}</td><td><a href = {"/games/".concat(name,"/player1")} >player1</a></td><td><a href = {"/games/".concat(name,"/player2")}>player2</a></td></tr>);
    return (<table>
                <thead>
                    <tr>
                        <th>Game Name</th>
                        <th>Click to choose player1</th>
                        <th>Click to choose player2</th>
                    </tr>
                </thead>
                <tbody>
                    {listItems}
                </tbody>
            </table>);
}
