defmodule CheckersWeb.GameChannel do
  use CheckersWeb, :channel
  alias Checkers.Game
  alias Checkers.GameBackup


  def join("game:" <> id, payload, socket) do
    if authorized?(payload) do
      game = GameBackup.load(id) || Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, id)
      GameBackup.save(socket.assigns[:name], game)
      {:ok, %{"game" => game}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("add_player", payload, socket) do
    game = Game.add_player(GameBackup.load(socket.assigns[:name]), payload["name"])
    socket = assign(socket, :game, game)
    GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "shout", %{"game" => game}
    {:noreply, socket}
  end

  def handle_in("first_click", payload, socket) do
    game = GameBackup.load(socket.assigns[:name])
    currentPlayer = Map.get(game, :currentPlayer)
    players = Map.get(game, :players)
    if payload["player_name"] == Enum.fetch!(players, String.to_integer(currentPlayer) - 1) do
      game = Game.get_paths(game, payload["clicks"], payload["index1"], payload["char1"], payload["player_name"])
      socket = assign(socket, :game, game)
      GameBackup.save(socket.assigns[:name], game)
      {:reply, {:ok, %{"game" => game}}, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_in("click", payload, socket) do
    game = GameBackup.load(socket.assigns[:name])
    currentPlayer = Map.get(game, :currentPlayer)
    players = Map.get(game, :players)
    if payload["player_name"] == Enum.fetch!(players, String.to_integer(currentPlayer) - 1) do
      case Game.update_state(GameBackup.load(socket.assigns[:name]), payload["index"], payload["index1"], payload["char1"], payload["player_name"]) do
        {:ok, game} ->
         socket = assign(socket, :game, game)
         GameBackup.save(socket.assigns[:name], game)
         broadcast socket, "shout", %{"game" => game}
         {:noreply, socket}
        {:error, game} ->
          socket = assign(socket, :game, game)
          GameBackup.save(socket.assigns[:name], game)
          {:reply, {:error, %{"game" => game }}, socket}
      end
    else
      {:noreply, socket}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("new", payload, socket) do
    game = Game.new()
    players = Map.get(GameBackup.load(socket.assigns[:name]), :players)
    if Enum.member?(players, payload["name"]) do
      players = Map.fetch!(GameBackup.load(socket.assigns[:name]), :players)
      if length(players) == 2 do
        if Enum.fetch!(players, 0) do
          game = Game.add_player(game, Enum.fetch!(players, 0))
        end
        if Enum.fetch!(players, 1) do
          game = Game.add_player(game, Enum.fetch!(players, 1))
        end
        game = Map.put(game, :clickable, true)
      end
      game = Map.put(game, :message, "New Game. " <> to_string(Enum.fetch!(players, 0)) <> " 's turn to Play")
      socket = assign(socket, :game, game)
      GameBackup.save(socket.assigns[:name], game)
      broadcast socket, "shout", %{"game" => game}
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_in("quit", payload, socket) do
    game = Game.delete_player(GameBackup.load(socket.assigns[:name]), payload["name"])
    socket = assign(socket, :game, game)
    GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "shout", %{"game" => game}
    {:noreply, socket}
  end

  def handle_in("new_msg", payload, socket) do
    broadcast socket, "new_msg", %{"msg" => payload["message"]}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
