defmodule Checkers.HighscoreTest do
  use Checkers.DataCase

  alias Checkers.Highscore

  describe "scores" do
    alias Checkers.Highscore.Score

    @valid_attrs %{game_time: ~T[14:00:00.000000], player1: "some player1", player2: "some player2"}
    @update_attrs %{game_time: ~T[15:01:01.000000], player1: "some updated player1", player2: "some updated player2"}
    @invalid_attrs %{game_time: nil, player1: nil, player2: nil}

    def score_fixture(attrs \\ %{}) do
      {:ok, score} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Highscore.create_score()

      score
    end

    test "list_scores/0 returns all scores" do
      score = score_fixture()
      assert Highscore.list_scores() == [score]
    end

    test "get_score!/1 returns the score with given id" do
      score = score_fixture()
      assert Highscore.get_score!(score.id) == score
    end

    test "create_score/1 with valid data creates a score" do
      assert {:ok, %Score{} = score} = Highscore.create_score(@valid_attrs)
      assert score.game_time == ~T[14:00:00.000000]
      assert score.player1 == "some player1"
      assert score.player2 == "some player2"
    end

    test "create_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Highscore.create_score(@invalid_attrs)
    end

    test "update_score/2 with valid data updates the score" do
      score = score_fixture()
      assert {:ok, score} = Highscore.update_score(score, @update_attrs)
      assert %Score{} = score
      assert score.game_time == ~T[15:01:01.000000]
      assert score.player1 == "some updated player1"
      assert score.player2 == "some updated player2"
    end

    test "update_score/2 with invalid data returns error changeset" do
      score = score_fixture()
      assert {:error, %Ecto.Changeset{}} = Highscore.update_score(score, @invalid_attrs)
      assert score == Highscore.get_score!(score.id)
    end

    test "delete_score/1 deletes the score" do
      score = score_fixture()
      assert {:ok, %Score{}} = Highscore.delete_score(score)
      assert_raise Ecto.NoResultsError, fn -> Highscore.get_score!(score.id) end
    end

    test "change_score/1 returns a score changeset" do
      score = score_fixture()
      assert %Ecto.Changeset{} = Highscore.change_score(score)
    end
  end
end
