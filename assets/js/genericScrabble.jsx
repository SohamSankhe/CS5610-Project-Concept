import React from 'react';
import ReactDOM from 'react-dom'; 

export default function scrabble_init(root) {
  ReactDOM.render(<GenericScrabble />, root);
}

class GenericScrabble extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return <div>
      <h2>React enabled.</h2>
    </div>;
  }
}
