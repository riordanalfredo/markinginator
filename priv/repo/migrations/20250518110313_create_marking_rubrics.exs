defmodule App.Repo.Migrations.CreateMarkingRubrics do
  use Ecto.Migration

  def change do
    create table(:marking_rubrics) do
      add :criteria, :text
      add :max_score, :integer
      add :assignment, references(:assignments, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:marking_rubrics, [:assignment])
  end
end
