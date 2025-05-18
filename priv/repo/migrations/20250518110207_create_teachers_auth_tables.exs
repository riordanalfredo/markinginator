defmodule App.Repo.Migrations.CreateTeachersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:teachers) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime
      add :role, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teachers, [:email])

    create table(:teachers_tokens) do
      add :teacher_id, references(:teachers, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:teachers_tokens, [:teacher_id])
    create unique_index(:teachers_tokens, [:context, :token])
  end
end
