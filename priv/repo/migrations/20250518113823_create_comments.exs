defmodule App.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :text, null: false
      add :created_by, references(:teachers, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:created_by])
  end
end
