defmodule Checkers.Game do

	 def new() do
    	%{
				board: [
					" ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
          " ", "1", " ", "1", " ", "1", " ", "1", " ", " ",
          " ", " ", "1", " ", "1", " ", "1", " ", "1", " ",
          " ", "1", " ", "1", " ", "1", " ", "1", " ", " ",
          " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
          " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
          " ", " ", "2", " ", "2", " ", "2", " ", "2", " ",
          " ", "2", " ", "2", " ", "2", " ", "2", " ", " ",
          " ", " ", "2", " ", "2", " ", "2", " ", "2", " ",
					" ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
        ],
    		score: 0,
    		noClick: 0,
    		index1: -1,
    		index2: -1,
    		char1: "",
    		char2: "",
    		clickable: false,
        currentPlayer: "1",
				kings: [
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false, false, false,
				],
				winner: "",
				players: [],
				message: "",
    	}
    end

 def add_player(state, player_name) do
 	players = state.players
	clickable = state.clickable
	message = player_name <> " joined the game"
	if(length(players) < 2 && !Enum.member?(players, player_name)) do
		players = players ++  [player_name]
		message = message <> " as Player " <> to_string(length(players))
	end
	if length(players) == 2 do
		clickable = true
		message = message <> ". " <> to_string(Enum.fetch!(state.players, String.to_integer(state.currentPlayer) - 1)) <> "'s turn to play!"
	end
	state = Map.put(state, :clickable, clickable)
	|> Map.put(:players, players)
	|> Map.put(:message, message)
	state
 end

 def delete_player(state, player_name) do
 	players = Map.fetch!(state, :players)
	if Enum.member?(players, player_name) do
		players = List.delete(players, player_name)
		state = new()
	end
	state = Map.put(state, :players, players)
	state = Map.put(state, :message, player_name <> " left the game!")
	state
 end

 def get_paths(state, clicks, index1, char1, player_name) do
 	if state.clickable do
		board = state.board
		if char1 == state.currentPlayer && player_name == Enum.fetch!(state.players, String.to_integer(state.currentPlayer) - 1) do
		 	index_board = Stream.with_index(board)
			board = Enum.map(index_board, fn({x, i}) -> if is_valid?(index1, i, board, state.kings) do "3" else x end end)
			Map.put(state, :board, board)
			|> Map.put(:noClick, state.noClick + 1)
			|> Map.put(:char1, char1)
			|> Map.put(:index1, index1)
			else
				Map.put(state, :noClick, state.noClick + 1)
			end
		else
			Map.put(state, :noClick, state.noClick)
 		end
	end

	def update_state(state, index, last_index, char, player_name) do
		if state.clickable do
			currentPlayer = state.currentPlayer
			nextPlayer = currentPlayer
			kings = state.kings
			winner = state.winner
			board = state.board
			if Enum.fetch!(board, index) == "3" do
					board = Enum.map(board, fn(x) -> if x == "3" do " " else x end end)
			    pos1 = Enum.fetch!(board, last_index)
					if player_name == Enum.fetch!(state.players, String.to_integer(currentPlayer) - 1) do
		        pos2 = Enum.fetch!(board, index)
		        board = List.replace_at(board, last_index, " ")
		        board = List.replace_at(board, index, char)
						if Enum.fetch!(kings, last_index) do
							kings = List.replace_at(kings, last_index, false)
			        kings = List.replace_at(kings, index, true)
						end
						if pos1 == "1" && index in 81..88 do
							kings = List.replace_at(kings, index, true)
						end
						if pos1 == "2" && index in 11..18 do
							kings = List.replace_at(kings, index, true)
						end
						if index == last_index + 18 || index == last_index + 22 ||
							 index == last_index - 18 || index == last_index - 22 do
							 	cond do
							 		index == last_index + 18 ->
										board = List.replace_at(board, last_index + 9, " ")
										if Enum.fetch!(kings, last_index + 9) do
											kings = List.replace_at(kings, last_index + 9, false)
										end
									index == last_index + 22 ->
										board = List.replace_at(board, last_index + 11, " ")
										if Enum.fetch!(kings, last_index + 11) do
											kings = List.replace_at(kings, last_index + 7, false)
										end
									index == last_index - 18 ->
										board = List.replace_at(board, last_index - 9, " ")
										if Enum.fetch!(kings, last_index - 9) do
											kings = List.replace_at(kings, last_index - 9, false)
										end
									index == last_index - 22 ->
										board = List.replace_at(board, last_index - 11, " ")
										if Enum.fetch!(kings, last_index - 11) do
											kings = List.replace_at(kings, last_index - 11, false)
										end
							 	end
						else
			        if currentPlayer == "1" do
			          nextPlayer = "2"
			        else
			          nextPlayer = "1"
			        end
						end
						if !Enum.any?(board, fn(x) -> x == "2" end) do
							winner = "1"
						end
						if !Enum.any?(board, fn(x) -> x == "1" end) do
							winner = "2"
						end
						message = to_string(Enum.fetch!(state.players, String.to_integer(nextPlayer) - 1)) <> "'s turn to play!"
		        %{
		          board: board,
		          score: state.score,
		          noClick: state.noClick + 1,
		      		index1: -1,
		      		index2: -1,
		      		char1: "",
		      		char2: "",
		      		clickable: state.clickable,
							currentPlayer: nextPlayer,
							kings: kings,
							winner: winner,
							players: state.players,
							message: message,
		        }
					else
						message = to_string(Enum.fetch!(state.players, String.to_integer(nextPlayer) - 1)) <> "'s turn to play!"
						board = Enum.map(board, fn(x) -> if x == "3" do " " else x end end)
						state = Map.put(state, :message, "Not a valid move")
						|> Map.put(:board, board)
						|> Map.put(:noClick, state.noClick + 1)
				end
			else
				board = state.board
				board = Enum.map(board, fn(x) -> if x == "3" do " " else x end end)
				state = Map.put(state, :message, "Not a valid move")
				|> Map.put(:noClick, state.noClick + 1)
				|> Map.put(:board, board)
			end
		end
	end

	def is_valid?(from, to, board, kings) do
		cond do
			Enum.fetch!(kings, from) == true ->
 			 cond do
  				(to == from + 9 || to == from + 11 || to == from - 9 || to == from - 11)
  				&& (Enum.fetch!(board, to) == " ")
  				&& (to != from) ->
  						true
  				((to == from + 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)))||
  				 (to == from + 22 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 11)))||
 				 	to == from - 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9))||
  					to == from - 22 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 11)))
  				&& (Enum.fetch!(board, to) == " ")
  				&& (to != from) ->
  						true
  				true->
  					false
  			end
		 Enum.fetch!(board, from ) == "1" ->
			cond do
				(to == from + 9 || to == from + 11)
				&& (Enum.fetch!(board, to) == " ")
				&& (to != from) ->
						true
				((to == from + 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)))||
				 (to == from + 22 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 11))))
				&& (Enum.fetch!(board, to) == " ")
				&& (to != from) ->
						true
				true->
					false
			end
			Enum.fetch!(board, from ) == "2" ->
			cond do
				(to == from - 11 || to == from - 9)
				&& (Enum.fetch!(board, to) == " ")
				&& (to != from) ->
						true
				(to == from - 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9))||
				to == from - 22 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 11)))
				&& (Enum.fetch!(board, to) == " ")
				&& (to != from) ->
						true
				true->
					false
			end
		end
	end

	def is_enemy?(current_piece, enemy) do
		cond do
			((current_piece == "1") && (enemy == "2")) -> true
			((current_piece == "2") && (enemy == "1")) -> true
			true -> false
		end
	end

end
