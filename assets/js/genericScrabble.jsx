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
    };

    this.channel.join()
        .receive("ok", this.onJoin.bind(this))
		    .receive("error", resp => { console.log("Unable to join", resp); });
  }

  // Event handlers

  handleBoardClick(ev) // handle square comp click
  {
    var ind = ev.target.value;
    console.log("Sq Index", ind, " Sq Value",
      this.state.board[ind]);

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
    console.log("Player chooses to play");
    // TODO: validate to prevent empty calls
    this.channel.push("play", {board: this.state.board,
      boardIndPlayed: this.state.boardIndPlayed,
      rackIndPlayed: this.state.rackIndPlayed})
  		.receive("ok", this.onUpdate.bind(this))
  }

  handleClearClick()
  {
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

  console.log(rackIndPlayed);

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
