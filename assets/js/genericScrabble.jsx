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
      whosturn: "player1"
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
    // TODO: validate to prevent empty calls
    this.channel.push("play", {board: this.state.board,
      boardIndPlayed: this.state.boardIndPlayed,
      rackIndPlayed: this.state.rackIndPlayed})
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

  render()
  {
    return(
        <div>
          <section className = "board">
            <h2>Current Round: {this.state.whosturn}</h2>
            <h2>{this.state.message}</h2>
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



// ref - onjoin from hangman
// ref: https://reactjs.org/tutorial/tutorial.html for Square function
