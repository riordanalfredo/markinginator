defmodule App.Repo.Migrations.CreateFeedbacks do
  use Ecto.Migration

  def change do
    create table(:feedbacks) do
      add :mark, :string
      add :comment, references(:comments, on_delete: :nothing)
      add :assignment, references(:assignments, on_delete: :nothing)
      add :student, references(:students, on_delete: :nothing)
      add :teacher, references(:teachers, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:feedbacks, [:comment])
    create index(:feedbacks, [:assignment])
    create index(:feedbacks, [:student])
    create index(:feedbacks, [:teacher])
  end
end
