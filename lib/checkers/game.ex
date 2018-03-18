defmodule Checkers.Game do

	 def new() do
    	%{
      	board: [
          "1", " ", "1", " ", "1", " ", "1", " ",
          " ", "1", " ", "1", " ", "1", " ", "1",
          "1", " ", "1", " ", "1", "", "1", " ",
          " ", " ", " ", " ", " ", " ", " ", " ",
          " ", " ", " ", " ", " ", " ", " ", " ",
          " ", "2", " ", "2", " ", "2", " ", "2",
          "2", " ", "2", " ", "2", " ", "2", " ",
          " ", "2", " ", "2", " ", "2", " ", "2",
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
					false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false,
					false, false, false, false, false, false, false, false,
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

	def update_state(state, index, last_index, char, player_name) do
		if state.clickable do
			currentPlayer = state.currentPlayer
			nextPlayer = currentPlayer
			kings = state.kings
			winner = state.winner
			board = state.board
			if is_valid?(last_index, index, board, kings) do
			    pos1 = Enum.fetch!(board, last_index)
					if player_name == Enum.fetch!(state.players, String.to_integer(currentPlayer) - 1) do
		        pos2 = Enum.fetch!(board, index)
		        board = List.replace_at(board, last_index, " ")
		        board = List.replace_at(board, index, char)
						if Enum.fetch!(kings, last_index) do
							kings = List.replace_at(kings, last_index, false)
			        kings = List.replace_at(kings, index, true)
						end
						if pos1 == "1" && index in 55..63 do
							kings = List.replace_at(kings, index, true)
						end
						if pos1 == "2" && index in 0..7 do
							kings = List.replace_at(kings, index, true)
						end
						if index == last_index + 18 || index == last_index + 14 ||
							 index == last_index - 18 || index == last_index - 14 do
							 	cond do
							 		index == last_index + 18 ->
										board = List.replace_at(board, last_index + 9, " ")
										if Enum.fetch!(kings, last_index + 9) do
											kings = List.replace_at(kings, last_index + 9, false)
										end
									index == last_index + 14 ->
										board = List.replace_at(board, last_index + 7, " ")
										if Enum.fetch!(kings, last_index + 7) do
											kings = List.replace_at(kings, last_index + 7, false)
										end
									index == last_index - 18 ->
										board = List.replace_at(board, last_index - 9, " ")
										if Enum.fetch!(kings, last_index - 9) do
											kings = List.replace_at(kings, last_index - 9, false)
										end
									index == last_index - 14 ->
										board = List.replace_at(board, last_index - 7, " ")
										if Enum.fetch!(kings, last_index - 7) do
											kings = List.replace_at(kings, last_index - 7, false)
										end
							 	end
						else
			        if currentPlayer == "1" do
			          nextPlayer = "2"
			        else
			          nextPlayer = "1"
			        end
							if !Enum.any?(board, fn(x) -> x == "2" end) do
								winner = "1"
							end
							if !Enum.any?(board, fn(x) -> x == "1" end) do
								winner = "2"
							end
						end
						message = to_string(Enum.fetch!(state.players, String.to_integer(nextPlayer) - 1)) <> "'s turn to play!"
		        %{
		          board: board,
		          score: state.score,
		          noClick: 0,
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
						state = Map.put(state, :message, message)
				end
			else
				state = Map.put(state, :message, "Not a valid move")
				state
			end
		end
	end

	def is_valid?(from, to, board, kings) do
		cond do
			Enum.fetch!(kings, from) == true ->
 			 cond do
  				(to == from + 9 || to == from + 7 || to == from - 9 || to == from - 7)
  				&& (Enum.fetch!(board, to) == " ")
  				&& (to != from) ->
  						true
  				((to == from + 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)))||
  				 (to == from + 14 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 7)))||
 				 	to == from - 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9))||
  					to == from - 14 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 7)))
  				&& (Enum.fetch!(board, to) == " ")
  				&& (to != from) ->
  						true
  				true->
  					false
  			end
		 Enum.fetch!(board, from ) == "1" ->
			cond do
				(to == from + 9 || to == from + 7)
				&& (Enum.fetch!(board, to) == " ")
				&& (to != from) ->
						true
				((to == from + 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)))||
				 (to == from + 14 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 7))))
				&& (Enum.fetch!(board, to) == " ")
				&& (to != from) ->
						true
				true->
					false
			end
			Enum.fetch!(board, from ) == "2" ->
			cond do
				(to == from - 9 || to == from - 7)
				&& (Enum.fetch!(board, to) == " ")
				&& (to != from) ->
						true
				(to == from - 18 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9))||
				to == from - 14 && is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 7)))
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
