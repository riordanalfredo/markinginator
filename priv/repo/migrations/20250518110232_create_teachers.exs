defmodule App.Repo.Migrations.CreateTeachers do
  use Ecto.Migration

  def change do
    create table(:teachers) do
      add :name, :string
      add :email, :string
      add :role, :string

      timestamps(type: :utc_datetime)
    end
  end
end
