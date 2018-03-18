defmodule CheckersWeb.ScoreController do
  use CheckersWeb, :controller

  alias Checkers.Highscore
  alias Checkers.Highscore.Score

  action_fallback CheckersWeb.FallbackController

  def index(conn, _params) do
    scores = Highscore.list_scores()
    render(conn, "index.json", scores: scores)
  end

  def create(conn, %{"player1" => player1, "player2" => player2, "hour" => start_hour, "minute" => start_minute,
  "second" => start_second}) do
    time = %DateTime{year: 0, month: 0, day: 0,
    hour: start_hour, minute: start_minute, second: start_second,
    zone_abbr: "AMT", time_zone: "America/Manaus",  utc_offset: -14400,
    std_offset: 0} |> DateTime.to_naive() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time()
    with {:ok, %Score{} = score} <- Highscore.create_score(%{player1: player1, player2: player2, game_time: time}) do
      conn
      |> put_status(:created)
      |> redirect(to: "/game/:game")
    end
  end

  def show(conn, %{"id" => id}) do
    score = Highscore.get_score!(id)
    render(conn, "show.json", score: score)
  end

  def update(conn, %{"id" => id, "score" => score_params}) do
    score = Highscore.get_score!(id)

    with {:ok, %Score{} = score} <- Highscore.update_score(score, score_params) do
      render(conn, "show.json", score: score)
    end
  end

  def delete(conn, %{"id" => id}) do
    score = Highscore.get_score!(id)
    with {:ok, %Score{}} <- Highscore.delete_score(score) do
      send_resp(conn, :no_content, "")
    end
  end
end
