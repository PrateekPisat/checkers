import React from 'react';
import ReactDOM from 'react-dom';
import { Stage, Layer, Rect, Circle } from 'react-konva';
import Konva from 'konva';


export default function run_demo(root, channel, name) {
  ReactDOM.render(<Demo channel={channel} playername={name}/>, root);
}

class Demo extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
	board: [],
	score:0,
	noClick: 0,
	index1: -1,
	index2: -1,
	char1: "",
	char2: "",
	clickable: true,
  currentPlayer: "",
  kings: [],
  winner: "",
  players: [],
  message: ""
 	};
    this.playername = props.playername
    this.name = props.name
    this.channel = props.channel
    this.channel.join()
        			  .receive("ok", resp => {console.log("Joined Game!")})
        			  .receive("error", resp => { console.log("Unable to join", resp) });
    this.channel.push("add_player", {name: this.playername}).receive("ok", resp => {console.log("Player Added")})
    this.channel.on("shout", this.passToState.bind(this))
  }



handleClick(index)
{
		if(this.state.clickable)
    {
      if(this.playername == this.state.players[parseInt(this.state.currentPlayer) - 1])
      {
        //console.log(index)
        if(this.state.noClick % 2 == 1 && this.state.noClick > 0)
  			   {
             this.channel.push("click", {index: index, index1: this.state.index1, char1: this.state.char1, player_name: this.playername})
                         .receive("error", this.passToState.bind(this))
         }
        else {
          this.channel.push("first_click", {clicks: this.state.noClick, char1: this.state.board[index], index1: index, player_name: this.playername})
                      .receive("ok", this.passToState.bind(this))
      }
    }
  }
}


passToState(gameState)
{
  console.log(gameState.game)
  if(!this.state.clickable && gameState.game.clickable)
  {
    var start_time = new Date();
    sessionStorage.setItem("start_time", start_time);
    sessionStorage.getItem("start_time")
  }
  if(gameState.game.winner == "1")
  {
    alert("Player 1 wins!");
    let current_time = new Date();
    let start_time = new Date(sessionStorage.getItem("start_time"));
    console.log(start_time);
    let startSecond = start_time.getSeconds();
    let startMinute = start_time.getMinutes();
    let startHour = start_time.getHours();
    let endSecond = current_time.getSeconds();
    let endMinute = current_time.getMinutes();
    let endHour = current_time.getHours();
    let text = JSON.stringify({
          player1: gameState.game.players[0],
          player2: gameState.game.players[1],
          second: endSecond - startSecond,
          minute: endMinute - startMinute,
          hour: endHour - startHour,
    });
    $.ajax(score_path, {
    method: "POST",
    dataType: "json",
    contentType: "application/json; charset=UTF-8",
    data: text,
  });
    this.newGame();
  }
  else if(gameState.game.winner == "2")
  {
    alert("Player 2 wins!");
    let current_time = new Date();
    let start_time = new Date(sessionStorage.getItem("start_time"));
    let startSecond = start_time.getSeconds();
    let startMinute = start_time.getMinutes();
    let startHour = start_time.getHours();
    let endSecond = current_time.getSeconds();
    let endMinute = current_time.getMinutes();
    let endHour = current_time.getHours();
    let text = JSON.stringify({
          player1: gameState.game.players[1],
          player2: gameState.game.players[0],
          second: endSecond - startSecond,
          minute: endMinute - startMinute,
          hour: endHour - startHour,
    });
    $.ajax(score_path, {
    method: "POST",
    dataType: "json",
    contentType: "application/json; charset=UTF-8",
    data: text,
  });
    this.newGame();
  }
  else
	 this.setState(gameState.game)
}

newGame()
{
  let start_time = new Date();
  sessionStorage.setItem("start_time", start_time)
	this.channel.push("new")
}

quit()
{
  this.channel.push("quit", {name: this.playername})
              .receive("ok", resp => {console.log(this.playername + " left the game.")})
  alert("Leaving the game")
  window.location.replace("/");
}

  render() {
    var toggle = 0;

		return (
		<div className="container-fluid">
      <div className="row">
        <div className="col">
          <h4>Player Name: {this.playername}.</h4>
        </div>
      </div>
      <div className="row">
        <div className="col">
          <h4>{this.state.message}</h4>
        </div>
      </div>
			<div className="row">
				<div className="col">
					<div className="board">
						{this.state.board.map((cell, index) => {
              if ((index >=11) && (index <= 88) && ![10, 20, 30, 40, 50, 60, 70, 80, 19, 29, 39, 49, 59, 69, 79, 89].includes(index) )
              {
              if (toggle % 2 == 1)
              {
                  if (index == 18 || index == 28 || index == 38 || index == 48 || index == 58 || index == 68 || index == 78)
                    toggle = toggle + 1;
                  if (index % 2 == 0)
                    {
                      if(cell=="1")
                        {
                          if(this.state.kings[index])
                          {
                            return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                            <span className="dot" id="white-king-checker"></span>
                            </div>
                          }
                          else
                          {
                            return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                            <span className="dot" id="white-checker"></span>
                            </div>
                          }
                        }
                      else if(cell=="2")
                        if(this.state.kings[index])
                        {
                          return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                            <span className="dot" id="black-king-checker"></span>
                          </div>
                        }
                        else
                        {
                          return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                            <span className="dot" id="black-checker"></span>
                          </div>
                        }
                      else if(cell=="3")
                        return <div className="path-square" 	onClick={() => this.handleClick(index)} >
                        </div>
                      else {
                          return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                          </div>
                        }
                    }
                  else
                    {
                      if(cell=="1")
                        {
                          if(this.state.kings[index])
                            return <div className="black-square" 	onClick={() => this.handleClick(index)} >
                              <span className="dot" id="white-king-checker"></span>
                            </div>
                          else {
                            return <div className="black-square" 	onClick={() => this.handleClick(index)} >
                              <span className="dot" id="white-checker"></span>
                            </div>
                          }
                        }
                      else if(cell=="2")
                      {
                        if(this.state.kings[index])
                          return <div className="black-square" 	onClick={() => this.handleClick(index)} >
                            <span className="dot" id="black-king-checker"></span>
                          </div>
                        else {
                          return <div className="black-square" 	onClick={() => this.handleClick(index)} >
                            <span className="dot" id="black-checker"></span>
                          </div>
                        }
                      }
                      else if(cell=="3")
                      return <div className="path-square" 	onClick={() => this.handleClick(index)} >

                      </div>
                      else {
                        return <div className="black-square">

                        </div>
                      }
                    }
                  }
              else
                {
                  if (index == 18 || index == 28 || index == 38 || index == 48 || index == 58 || index == 68 || index == 78)
                    toggle = toggle + 1;
                  if (index % 2 == 1)
                  {
                    if(cell=="1")
                    {
                      if(this.state.kings[index])
                        return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                          <span className="dot" id="white-king-checker"></span>
                        </div>
                      else {
                        return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                          <span className="dot" id="white-checker"></span>
                        </div>
                      }
                    }
                    else if(cell=="2")
                    {
                      if(this.state.kings[index])
                        return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                          <span className="dot" id="black-king-checker"></span>
                        </div>
                      else {
                        return <div className="white-square" 	onClick={() => this.handleClick(index)} >
                          <span className="dot" id="black-checker"></span>
                        </div>
                      }
                    }
                    else if(cell=="3")
                    return <div className="path-square" 	onClick={() => this.handleClick(index)} >
                    </div>
                    else {
                      return <div className="white-square" 	onClick={() => this.handleClick(index)} >

                      </div>
                    }
                  }
                  else
                    return <div className="black-square"  >{cell}</div>
                }
              }
            }
          )
        }
					</div>
				</div>
				<div className="col">
					<div className="row">
						<button className="btn btn-info" name="Restart" onClick={() => this.newGame()} >New Game</button>
					</div>
          <div className="row">
						<button className="btn btn-info" name="Quit" onClick={() => this.quit()} >Leave Game</button>
					</div>
				</div>
		      </div>
		 </div>
    		);
	}
}
