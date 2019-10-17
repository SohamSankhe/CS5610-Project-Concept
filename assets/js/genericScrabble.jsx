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
      color: []
    };

    this.channel
        .join()
        .receive("ok", this.onJoin.bind(this))
		    .receive("error", resp => { console.log("Unable to join", resp); });
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
    console.log("ctr ", ctr);

    return trs;
  }

  render()
  {
    return(
        <div>
          <table>
            <tbody>{this.getTable()}</tbody>
          </table>
        </div>
    );
  }

  getSquare(i)
  {
    return(
      <Square letter={this.state.board[i]}
       color={this.state.color[i]}/>
    );
  }
}

function Square(props)
{
  let clr = props.color;
  let butStyles = {
    color: "black",
    backgroundColor: clr
  };

  return(
    <button className = "but" style = {butStyles}>
      {props.letter}
    </button>
  );
}



// ref - onjoin from hangman
// ref: https://reactjs.org/tutorial/tutorial.html for Square function
