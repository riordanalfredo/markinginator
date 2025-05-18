defmodule App.MarkingRubric do
  use Ecto.Schema
  import Ecto.Changeset

  schema "marking_rubrics" do
    field :criteria, :string
    field :max_score, :integer
    belongs_to :assignment, App.Assignment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(marking_rubric, attrs) do
    marking_rubric
    |> cast(attrs, [:assignment_id, :criteria, :max_score])
    |> validate_required([:assignment_id, :criteria, :max_score])
  end
end
