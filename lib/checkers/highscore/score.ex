defmodule Checkers.Highscore.Score do
  use Ecto.Schema
  import Ecto.Changeset


  schema "scores" do
    field :game_time, :time
    field :player1, :string
    field :player2, :string

    timestamps()
  end

  @doc false
  def changeset(score, attrs) do
    score
    |> cast(attrs, [:player1, :player2, :game_time])
    |> validate_required([:player1, :player2, :game_time])
  end
end
