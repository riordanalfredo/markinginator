defmodule App.Teachers.Teacher do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teachers" do
    field :name, :string
    field :role, :string
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, [:name, :email, :role])
    |> validate_required([:name, :email, :role])
  end
end
