defmodule CheckersWeb.ScoreView do
  use CheckersWeb, :view
  alias CheckersWeb.ScoreView

  def render("index.json", %{scores: scores}) do
    %{data: render_many(scores, ScoreView, "score.json")}
  end

  def render("show.json", %{score: score}) do
    %{data: render_one(score, ScoreView, "score.json")}
  end

  def render("score.json", %{score: score}) do
    %{id: score.id,
      player1: score.player1,
      player2: score.player2,
      game_time: score.game_time}
  end
end
