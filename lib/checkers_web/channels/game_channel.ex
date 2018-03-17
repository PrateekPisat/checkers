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

  def handle_in("click", payload, socket) do
    game = Game.update_state(GameBackup.load(socket.assigns[:name]), payload["index"], payload["index1"], payload["char1"], payload["player_name"])
    socket = assign(socket, :game, game)
    GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "shout", %{"game" => game}
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("new", payload, socket) do
    game = Game.new()
    players = Map.fetch!(GameBackup.load(socket.assigns[:name]), :players)
    if length(players) == 2 do
      if Enum.fetch!(players, 0) do
        game = Game.add_player(game, Enum.fetch!(players, 0))
      end
      if Enum.fetch!(players, 1) do
        game = Game.add_player(game, Enum.fetch!(players, 1))
      end
      Map.put(game, :players, true)
    end
    socket = assign(socket, :game, game)
    GameBackup.save(socket.assigns[:name], game)
    broadcast socket, "shout", %{"game" => game}
    {:noreply, socket}
end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
