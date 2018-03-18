defmodule CheckersWeb.PageController do
  use CheckersWeb, :controller
  alias Checkers.NoChannels
  alias Checkers.Highscore

  def index(conn, _params) do
    no_channels = NoChannels.load("Checkers") || [1]
    NoChannels.save("Checkers", no_channels)
    scores = Highscore.highscore()
    render conn, "index.html", no_channels: no_channels, scores: scores
  end

  def game(conn, _params) do
    render conn, "game.html"
  end

  def newchannel(conn, _) do
    no_channels = NoChannels.load("Checkers")
    no_channels = no_channels ++ [length(no_channels) + 1]
    NoChannels.save("Checkers", no_channels)
    redirect(conn, to: "/", no_channels: no_channels)
  end

  def deletechannel(conn, _) do
    no_channels = NoChannels.load("Checkers")
    if length(no_channels) >= 1 do
      no_channels = List.delete(no_channels, List.last(no_channels))
      NoChannels.save("Checkers", no_channels)
    end
    redirect(conn, to: "/", no_channels: no_channels)
  end
end
