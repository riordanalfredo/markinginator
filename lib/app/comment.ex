defmodule App.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :text, :string
    belongs_to :created_by, App.Teacher

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:text, :created_by_id])
    |> validate_required([:text, :created_by_id])
  end
end
