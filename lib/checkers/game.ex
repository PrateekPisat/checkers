defmodule Checkers.Game do

	 def new() do
    	%{
				board: [
					"0", "0", "0", "0", "0", "0", "0", "0", "0", "0",
          "0", "1", " ", "1", " ", "1", " ", "1", " ", "0",
          "0", " ", "1", " ", "1", " ", "1", " ", "1", "0",
          "0", "1", " ", "1", " ", "1", " ", "1", " ", "0",
          "0", " ", " ", " ", " ", " ", " ", " ", " ", "0",
          "0", " ", " ", " ", " ", " ", " ", " ", " ", "0",
          "0", " ", "2", " ", "2", " ", "2", " ", "2", "0",
          "0", "2", " ", "2", " ", "2", " ", "2", " ", "0",
          "0", " ", "2", " ", "2", " ", "2", " ", "2", "0",
					"0", "0", "0", "0", "0", "0", "0", "0", "0", "0",
        ],
    		score: 0,
    		noClick: 0,
    		index1: -1,
    		char1: "",
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
				startHours: 0,
				startMinutes: 0,
				startSeconds: 0,
    	}
    end

 def add_player(state, player_name) do
 	players = state.players
	clickable = state.clickable
	startHours = state.startHours
	startMinutes = state.startMinutes
	startSeconds = state.startSeconds
	message = player_name <> " joined the game"
	if(length(players) < 2 && !Enum.member?(players, player_name)) do
		players = players ++  [player_name]
		message = message <> " as Player " <> to_string(length(players))
	end
	if length(players) == 2 do
		if startHours== 0 && startMinutes == 0 && startSeconds==0 do
			{{_, _, _}, {startHours, startMinutes, startSeconds}} = :calendar.local_time()
		end
		clickable = true
		message = message <> ". " <> to_string(Enum.fetch!(state.players, String.to_integer(state.currentPlayer) - 1)) <> "'s turn to play!"
	end
	state = Map.put(state, :clickable, clickable)
	|> Map.put(:players, players)
	|> Map.put(:startHours, startHours)
	|> Map.put(:startMinutes, startMinutes)
	|> Map.put(:startSeconds, startSeconds)
	|> Map.put(:message, message)
 end

 def delete_player(state, player_name) do
 	players = Map.fetch!(state, :players)
	if Enum.member?(players, player_name) do
		players = List.delete(players, player_name)
		state = new()
	end
	state = Map.put(state, :players, players)
	state = Map.put(state, :message, player_name <> " left the game!")
 end

 def get_paths(state, clicks, index1, char1, player_name) do
 	if state.clickable do
		board = state.board
		if char1 == state.currentPlayer do
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
						if !Enum.any?(board, fn(x) -> x == "2" end) || !(no_more_moves("2", board, kings)) do
							winner = "1"
							{{_, _, _}, {hours, minutes, seconds}} = :calendar.local_time()
							time = %DateTime{year: 0, month: 0, day: 0,
					    hour: hours, minute: minutes, second: seconds,
					    zone_abbr: "AMT", time_zone: "America/Manaus",  utc_offset: -14400,
					    std_offset: 0} |> DateTime.to_naive() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time()
							start_time = %DateTime{year: 0, month: 0, day: 0,
					    hour: state.startHours, minute: state.startMinutes, second: state.startSeconds,
					    zone_abbr: "AMT", time_zone: "America/Manaus",  utc_offset: -14400,
					    std_offset: 0} |> DateTime.to_naive() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time()
							total_time = Time.diff(time, start_time)
					    hour = div(total_time, 3600)
					    minute = div(rem(total_time, 3600), 60)
					    second = rem(rem(total_time, 3600), 60)
					    time = %DateTime{year: 0, month: 0, day: 0,
					    hour: hour, minute: minute, second: second,
					    zone_abbr: "AMT", time_zone: "America/Manaus",  utc_offset: -14400,
					    std_offset: 0} |> DateTime.to_naive() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time()
							state = Map.put(state, :startHours, hour)
							|> Map.put(:startSeconds, second)
							|> Map.put(:startMinutes, minute)

						end
						if !Enum.any?(board, fn(x) -> x == "1" end) || !(no_more_moves("1", board, kings)) do
							winner = "2"
							{{_, _, _}, {hours, minutes, seconds}} = :calendar.local_time()
							time = %DateTime{year: 0, month: 0, day: 0,
					    hour: hours, minute: minutes, second: seconds,
					    zone_abbr: "AMT", time_zone: "America/Manaus",  utc_offset: -14400,
					    std_offset: 0} |> DateTime.to_naive() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time()
							start_time = %DateTime{year: 0, month: 0, day: 0,
					    hour: state.startHours, minute: state.startMinutes, second: state.startSeconds,
					    zone_abbr: "AMT", time_zone: "America/Manaus",  utc_offset: -14400,
					    std_offset: 0} |> DateTime.to_naive() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time()
							total_time = Time.diff(time, start_time)
							hour = div(total_time, 3600)
							minute = div(rem(total_time, 3600), 60)
							second = rem(rem(total_time, 3600), 60)
							time = %DateTime{year: 0, month: 0, day: 0,
							hour: hour, minute: minute, second: second,
							zone_abbr: "AMT", time_zone: "America/Manaus",  utc_offset: -14400,
							std_offset: 0} |> DateTime.to_naive() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time()
							state = Map.put(state, :startHours, hour)
							|> Map.put(:startSeconds, second)
							|> Map.put(:startMinutes, minute)
						end
						message = to_string(Enum.fetch!(state.players, String.to_integer(nextPlayer) - 1)) <> "'s turn to play!"
						state = Map.put(state, :board, board)
						|> Map.put(:noClick, state.noClick+1)
						|> Map.put(:index1, -1)
						|> Map.put(:char1, "")
						|> Map.put(:currentPlayer, nextPlayer)
						|> Map.put(:kings, kings)
						|> Map.put(:winner, winner)
						|> Map.put(:message, message)
						{:ok, state}
			else
				board = state.board
				board = Enum.map(board, fn(x) -> if x == "3" do " " else x end end)
				state = Map.put(state, :message, "Not a valid move")
				|> Map.put(:noClick, state.noClick + 1)
				|> Map.put(:board, board)
				{:error, state}
			end
		else
			{:error, state}
		end
	end

	def is_valid?(from, to, board, kings) do
		cond do
			Enum.fetch!(kings, from) == true ->
 			 cond do
  				to == from + 9
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 11)) && Enum.fetch!(board, from + 22) == " ")
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9)) && Enum.fetch!(board, from - 18) == " ")
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 11)) && Enum.fetch!(board, from - 22) == " ")
  				&& (Enum.fetch!(board, to) == " ")
  				&& (to != from) ->
  						true
				 to == from + 11
				 && !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)) && Enum.fetch!(board, from + 18) == " ")
				 && !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 11)) && Enum.fetch!(board, from - 22) == " ")
				 && !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9)) && Enum.fetch!(board, from - 18) == " ")
				 && (Enum.fetch!(board, to) == " ")
		  	 && (to != from) ->
							true

					to == from - 9
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 11)) && Enum.fetch!(board, from - 22) == " ")
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 11)) && Enum.fetch!(board, from + 22) == " ")
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)) && Enum.fetch!(board, from + 18) == " ")
					&& (Enum.fetch!(board, to) == " ")
					&& (to != from) ->
								true

					to == from - 11
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9)) && Enum.fetch!(board, from - 18) == " ")
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)) && Enum.fetch!(board, from + 18) == " ")
					&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 11)) && Enum.fetch!(board, from + 22) == " ")
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
				(to == from + 9)
				&& (Enum.fetch!(board, to) == " ")
				&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 11)) && Enum.fetch!(board, from + 22) == " ")
				&& (to != from) ->
						true
				to == from + 11
				&& (Enum.fetch!(board, to) == " ")
				&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from + 9)) && Enum.fetch!(board, from + 18) == " ")
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

				(to == from - 11)
				&& (Enum.fetch!(board, to) == " ")
				&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 9)) && Enum.fetch!(board, from - 18) == " ")
				&& (to != from) ->
						true
				to == from - 9
				&& (Enum.fetch!(board, to) == " ")
				&& !(is_enemy?(Enum.fetch!(board, from), Enum.fetch!(board, from - 11)) && Enum.fetch!(board, from - 22) == " ")
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

	def no_more_moves(piece, board, kings) do
		index_board = Stream.with_index(board)
		only_this_piece = Enum.filter(index_board, fn({x, i}) -> if {x,i} == {piece, i} do {x, i} end end)
		valid_moves = Enum.map(only_this_piece, fn({x, index1}) -> Enum.any?(index_board, fn({_, i}) -> if is_valid?(index1, i, board, kings) do true else false end end) end)
		Enum.any?(valid_moves, fn(x) -> if x do true end end)
	end

end
