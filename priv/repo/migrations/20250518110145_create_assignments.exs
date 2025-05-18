defmodule App.Repo.Migrations.CreateAssignments do
  use Ecto.Migration

  def change do
    create table(:assignments) do
      add :title, :string
      add :description, :text
      add :due_date, :date

      timestamps(type: :utc_datetime)
    end
  end
end
