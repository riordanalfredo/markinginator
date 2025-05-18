defmodule App.Assignments.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assignments" do
    field :description, :string
    field :title, :string
    field :due_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast(attrs, [:title, :description, :due_date])
    |> validate_required([:title, :description, :due_date])
  end
end
