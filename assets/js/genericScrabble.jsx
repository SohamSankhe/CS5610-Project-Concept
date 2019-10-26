import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

// Reference for init and join/updates - hangman example done in class
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

    //this.channel.on("update", this.onJoin.bind(this));
    this.channel.on("update", this.onBroadcast.bind(this));
  }

  // Event handlers

  handleBoardClick(ev) // handle square comp click
  {
    if (!this.state.isActive || (this.state.whosturn != window.player)){
      return;
    }
    var ind = ev.target.value;

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
    if (!this.state.isActive || (this.state.whosturn != window.player)){
      return;
    }
    var ind = ev.target.value;
    if(this.state.rackIndPlayed.includes(ind.toString()))
    {
      return; // already played
    }
    this.setState(oldState => ({currentRackIndex : ind}));
  }

  handlePlayClick()
  {
    if (!this.state.isActive || (this.state.whosturn != window.player)){
      return;
    }
    this.displayState();

    this.channel.push("play", {board: this.state.board,
      boardIndPlayed: this.state.boardIndPlayed,
      rackIndPlayed: this.state.rackIndPlayed})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleSwapClick()
  {
    if (!this.state.isActive || (this.state.whosturn != window.player)){
      return;
    }
    if(this.state.currentRackIndex == -1)
    {
      this.setState(oldState => ({message: "Select a tile in the rack to swap"}));
      return;
    }
    this.channel.push("swap", {currentRackIndex: this.state.currentRackIndex})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleClearClick()
  {
    if (!this.state.isActive || (this.state.whosturn != window.player)){
      return;
    }

    this.setState(oldState => ({
      board: oldState.board.map((item, index) =>
          (oldState.boardIndPlayed.includes(index.toString())) ? "" : item
        ),
      boardIndPlayed: [], rackIndPlayed: [], currentRackIndex: -1
    }));
  }

  handlePassClick()
  {
    if (!this.state.isActive || (this.state.whosturn != window.player)){
      return;
    }
    this.channel.push("pass", {currentRackIndex: this.state.currentRackIndex})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleForfeitClick()
  {
    if (!this.state.isActive || (this.state.whosturn != window.player)){
      return;
    }
    this.channel.push("forfeit", {currentRackIndex: this.state.currentRackIndex})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleRestartClick()
  {
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
          <div className = "message-class">
            {this.getCurrentRound()}
            <p>{this.state.message}</p>
            {this.getRestart()}
          </div>
           <div className = "row">
              <div className = "column">
                <section className = "board">
                  <table>
                    <tbody>{this.getTable()}</tbody>
                  </table>
                </section>
              </div>
              <div className = "column">
                <section className = "rack">
                  {this.getRack()}
                </section>
                <section className = "actions">
                  <button className = "playButton"
                    onClick ={this.handlePlayClick.bind(this)}>Play</button>
                  <button className = "clearButton"
                    onClick ={this.handleClearClick.bind(this)}>Clear</button>
                  <button className = "swapButton"
                    onClick ={this.handleSwapClick.bind(this)}>Swap</button>
                  <button className = "passButton"
                    onClick ={this.handlePassClick.bind(this)}>Pass</button>
                  &nbsp;&nbsp;
                  <button className = "forfeitButton"
                    onClick ={this.handleForfeitClick.bind(this)}>Give up!</button>
                </section>
                <section className = "score-section">
                  <h3>Scores:</h3>
                  <p>Player 1: Score - {this.state.score1}, Last Round Score - {this.state.lastScore1} </p>
                  <p>Player 2: Score - {this.state.score2}, Last Round Score - {this.state.lastScore2} </p>
                </section>
                <section className="words-played">
                  <h3>Word(s) Played:</h3>
                  <p>{this.getWords()}</p>
                </section>
                <section id = "chat_room">
                  <h2 id = "chat"> Chat Box </h2>
                  <div id = "chat-box">
                    <textarea id = "user-box" value={this.state.chatMessage}></textarea>
                  </div>
                  <textarea id = "user-msg" placeholder = "Write your comment"></textarea><br></br>
                  <button id = "msg-button" type = "submit" onClick={this.handleSubmitClick.bind(this)}>Submit</button>
                </section>
              </div>
          </div>
      </div>
    );
  }

  getWords()
  {
    let wordsPlayed = this.state.words;
    console.log(wordsPlayed);
    let wordStr = "";
    for(let i = 0; i < wordsPlayed.length; i++)
    {
      console.log(wordsPlayed[i]);
      wordStr = wordStr.concat(" ", wordsPlayed[i]);
    }
    return (<span>{wordStr}</span>);
  }

  // Reference for Square: React JS tutorial on the official site
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

  getCurrentRound()
  {
    if(this.state.isActive)
    {
      return (
        <h2>Current Round: {this.state.whosturn}</h2>
      );
    }
  }

  onBroadcast(view)
  {
    console.log("broadcast");
    let newState = view.game;
    newState.rack = this.state.rack;
    console.log(newState);
    this.setState(newState);
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
  tbl.push(<table className = "rackTable"><tbody>{trs}</tbody></table>);
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
