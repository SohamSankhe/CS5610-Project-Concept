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
    	msg: ""
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

  render() {
    return <div>
      <h2>Msg: {this.state.msg}</h2>
    </div>;
  }
}



// ref - onjoin from hangman
