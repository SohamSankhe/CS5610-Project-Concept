import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function scrabble_init(root, channel) {
  ReactDOM.render(<GenericScrabble channel = {channel} />, root);
}

class GenericScrabble extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;

    this.state = {
      board: [],
      color: [],
      rack: [],
      currentRackIndex: -1,
      rackIndPlayed: [],
      boardIndPlayed: [],
      message: "",
      words: [],
      score1: 0,
      score2: 0,
      lastScore1: 0,
      lastScore2: 0,
      whosturn: "player1",
      isActive: true,
      chatMessage: "",
    };

    this.channel.join()
        .receive("ok", this.onJoin.bind(this))
		    .receive("error", resp => { console.log("Unable to join", resp); });

    this.channel.on("update", this.onJoin.bind(this));
  }

  // Event handlers

  handleBoardClick(ev) // handle square comp click
  {
    if (this.state.whosturn != window.player){
      return;
    }
    var ind = ev.target.value;
    console.log("Sq Index", ind, " Sq Value", this.state.board[ind]);

    if(this.state.board[ind] != "") {
      return; // value already exists - ignore
    }
    if(this.state.currentRackIndex == -1){
      return; // nothing selected
    }

    var rackValue = this.state.rack[this.state.currentRackIndex];
    var newRackIndPlayedList = this.state.rackIndPlayed.slice();
    newRackIndPlayedList.push(this.state.currentRackIndex);
    var newBoardIndPlayedList = this.state.boardIndPlayed.slice();
    newBoardIndPlayedList.push(ind);

    this.setState(oldState => ({
      board: oldState.board.map((item, index) => (index == ind) ? rackValue : item),
      currentRackIndex: -1,
      rackIndPlayed: newRackIndPlayedList,
      boardIndPlayed: newBoardIndPlayedList
    }));

    this.displayState();
  }

  handleRackClick(ev)
  {
    if (this.state.whosturn != window.player){
      return;
    }
    var ind = ev.target.value;
    console.log("Rack Index ", ind, " Value: ",
      this.state.rack[ind]);
    if(this.state.rackIndPlayed.includes(ind.toString()))
    {
      return; // already played
    }
    this.setState(oldState => ({currentRackIndex : ind}));
  }

  handlePlayClick()
  {
    if (this.state.whosturn != window.player){
      return;
    }
    console.log("Player chooses to play");
    this.displayState();

    this.channel.push("play", {board: this.state.board,
      boardIndPlayed: this.state.boardIndPlayed,
      rackIndPlayed: this.state.rackIndPlayed})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleSwapClick()
  {
    if (this.state.whosturn != window.player){
      return;
    }
    if(this.state.currentRackIndex == -1)
    {
      this.setState(oldState => ({message: "Select a tile in the rack to swap"}));
      return;
    }
    console.log("Player chooses to swap a tile");
    this.channel.push("swap", {currentRackIndex: this.state.currentRackIndex})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleClearClick()
  {
    if (this.state.whosturn != window.player){
      return;
    }
    console.log("Player chooses to clear");

    this.setState(oldState => ({
      board: oldState.board.map((item, index) =>
          (oldState.boardIndPlayed.includes(index.toString())) ? "" : item
        ),
      boardIndPlayed: [], rackIndPlayed: [], currentRackIndex: -1
    }));
  }

  handlePassClick()
  {
    if (this.state.whosturn != window.player){
      return;
    }
    console.log("Player chooses to pass the turn");
    this.channel.push("pass", {currentRackIndex: this.state.currentRackIndex})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleForfeitClick()
  {
    if (this.state.whosturn != window.player){
      return;
    }
    console.log("Player chooses to give up");
    this.channel.push("forfeit", {currentRackIndex: this.state.currentRackIndex})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleRestartClick()
  {
    console.log("Player chooses to playAgain");
    this.channel.push("playAgain", {currentRackIndex: this.state.currentRackIndex})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleSubmitClick()
  {
    let msg = document.getElementById("user-msg").value;
    document.getElementById("user-msg").value = "";

    if (msg == ""){
      return;
    }
    msg = window.player+ ": " + msg +"\n";
    let newChatMessage = this.state.chatMessage.concat(msg);
    this.setState(oldState => ({
      chatMessage: oldState.chatMessage.concat(msg)
    }));

    let msgArray = newChatMessage.split();
    this.channel.push("chatMessage", {msg: msgArray});
  }
  render()
  {
    return(
        <div>
          <section className = "board">
            <h2>Current Round: {this.state.whosturn}</h2>
            <h2>{this.state.message}</h2>
            {this.getRestart()}
            <table>
              <tbody>{this.getTable()}</tbody>
            </table>
          </section>
          <section className="racks">
          <h4>Player racks</h4>
            {this.getRack()}
            <button className = "playButton"
              onClick ={this.handlePlayClick.bind(this)}>Play</button>
            <button className = "clearButton"
              onClick ={this.handleClearClick.bind(this)}>Clear</button>
            <button className = "swapButton"
              onClick ={this.handleSwapClick.bind(this)}>Swap</button>
            <button className = "passButton"
              onClick ={this.handlePassClick.bind(this)}>Pass</button>
            <button className = "forfeitButton"
              onClick ={this.handleForfeitClick.bind(this)}>Give up!</button>
          </section>
          // TODO: make score comp
          <section className = "score">
            <h3>Score:</h3>
            <span><h4>Player 1: {this.state.score1}</h4></span>
            <span><h4>Player 2: {this.state.score2}</h4></span>
          </section>
          <section>
            <h3>Words Played:</h3>
            <h4>{this.state.words}</h4>
          </section>
          <section id = "chat_room">
            <h2 id = "chat"> Chat Box </h2>
            <div id = "chat-box">
              <textarea id = "user-box" value={this.state.chatMessage}></textarea>
              <br></br>
            </div>
            <textarea id = "user-msg" placeholder = "write your comment"></textarea><br></br>
            <br></br>
            <button id = "msg-button" type = "submit" onClick={this.handleSubmitClick.bind(this)}>Submit</button>

          </section>
        </div>
    );
  }

  getSquare(i)
  {
    return(
      <Square letter={this.state.board[i]}
       color={this.state.color[i]}
       indexVal = {i}
       onClick = {this.handleBoardClick.bind(this)}/>
    );
  }

  getRack()
  {
    return(
        <Rack letters={this.state.rack}  //Todo : add play and clear buttons
              onClick = {this.handleRackClick.bind(this)}
              currentRackIndex = {this.state.currentRackIndex}
              rackIndPlayed = {this.state.rackIndPlayed}/>
    );
  }

  getRestart()
  {
    return(
      <Restart msg = "Play Again" isGameActive = {this.state.isActive}
        onClick = {this.handleRestartClick.bind(this)}/>
    );
  }

  onJoin(view) {
    console.log("new view", view);
    this.setState(view.game);
  }


  onUpdate({game}){
    console.log("On update")
    console.log("new game", game)
    this.setState(game);
  }

  // Ref: https://stackoverflow.com/questions/22876978/loop-inside-react-jsx
  getTable()
  {
    let ctr = 0;
    let trs = [];
    for(let i = 0; i < 15; i++) // rows
    {
      let tds = [];
      for(let j = 0; j < 15; j++)
      {
          tds.push(<td>{this.getSquare(ctr)}</td>);
          ctr = ctr + 1;
      }
      trs.push(<tr>{tds}</tr>);
      //ctr = ctr + 1;
    }
    return trs;
  }

  getMessage()
  {
    var msg = this.state.message;
    var msgDisplay = [];
    if(msg != "")
    {
      msgDisplay.push(<p>{msg}</p>);
    }
    return msgDisplay;
  }

  displayState()
  {
    console.log(this.state);
  }
}

function Rack(props)
{
  let rackList = props.letters;
  let currentRackIndex = props.currentRackIndex;
  let rackIndPlayed = props.rackIndPlayed;
  let tbl = [];
  let trs = [];
  let tds = [];


  for(let i = 0; i < 7; i++)
  {
    let color = "white";
    if(currentRackIndex == i)
    {
      color = "red";
    }
    else if(rackIndPlayed.includes(i.toString()))
    {
      color = "green";
    }

    let butStyles = {
      backgroundColor: color
    };

    tds.push(<td>
        <button className = "rackButton"
          style = {butStyles}
          onClick={props.onClick}
          value = {i}>{rackList[i]}</button>
      </td>);
  }
  trs.push(<tr>{tds}</tr>);
  tbl.push(<table><tbody>{trs}</tbody></table>);
  return tbl;
}

function Square(props)
{
  let clr = props.color;
  let butStyles = {
    color: "black",
    backgroundColor: clr
  };

  return(
    <button className = "but"
      value = {props.indexVal}
      onClick = {props.onClick}
      style = {butStyles}>
      {props.letter}
    </button>
  );
}

function Restart(props)
{
  if (!props.isGameActive)
  {
      console.log("here 1");
      return(
        <button className = "restartButton"
          onClick = {props.onClick}>
          {props.msg}
        </button>
      );
  }
  else {
    return null;
  }
}



// ref - onjoin from hangman
// ref: https://reactjs.org/tutorial/tutorial.html for Square function
