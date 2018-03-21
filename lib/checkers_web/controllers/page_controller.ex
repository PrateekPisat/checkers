defmodule CheckersWeb.PageController do
  use CheckersWeb, :controller
  alias Checkers.NoChannels
  alias Checkers.Highscore
  alias Checkers.GameBackup

  def index(conn, _params) do
    no_channels = NoChannels.load("Checkers") || [1]
    NoChannels.save("Checkers", no_channels)
    scores = Highscore.highscore()
    render conn, "index.html", no_channels: no_channels, scores: scores
  end

  def game(conn, %{"name" => name, "channel-id" => channelid}) do
    if GameBackup.load(channelid) do
      game = GameBackup.load(channelid)
      players = Map.get(game, :players)
      if Enum.member?(players, name) do
        conn = put_flash(conn, :error, "The Player Name is alaready Taken. Please choose another.")
        redirect(conn, to: "/")
      else
        render conn, "game.html"
      end
    else
      render conn, "game.html"
    end
  end

  def newchannel(conn, _) do
    no_channels = NoChannels.load("Checkers")
    no_channels = no_channels ++ [length(no_channels) + 1]
    NoChannels.save("Checkers", no_channels)
    conn = put_flash(conn, :info, "Lobby " <> to_string(length(no_channels)) <> " created")
    redirect(conn, to: "/", no_channels: no_channels)
  end

  def deletechannel(conn, _) do
    no_channels = NoChannels.load("Checkers")
    if length(no_channels) > 1 do
      if GameBackup.load(to_string(List.last(no_channels))) do
        game = GameBackup.load(to_string(List.last(no_channels)))
        players = Map.get(game, :players)
        if length(players) == 0 do
          no_channels = List.delete(no_channels, List.last(no_channels))
          conn = put_flash(conn, :info, "Lobby " <> to_string(length(no_channels) + 1) <> " Deleted")
          NoChannels.save("Checkers", no_channels)
          redirect(conn, to: "/", no_channels: no_channels)
        else
          conn = put_flash(conn, :error, "There are players in that lobby")
          redirect(conn, to: "/", no_channels: no_channels)
        end
      else
        no_channels = List.delete(no_channels, List.last(no_channels))
        conn = put_flash(conn, :info, "Lobby " <> to_string(length(no_channels) + 1) <> " Deleted")
        NoChannels.save("Checkers", no_channels)
        redirect(conn, to: "/", no_channels: no_channels)
      end
    else
      conn = put_flash(conn, :error, "Need atleast 1 Lobby")
      redirect(conn, to: "/", no_channels: no_channels)
    end
  end
end
