defmodule Checkers.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :player1, :string, null: false
      add :player2, :string, null: false
      add :game_time, :time, null: false

      timestamps()
    end

  end
end
