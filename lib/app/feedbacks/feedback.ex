defmodule App.Students.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedbacks" do
    field :mark, :string
    belongs_to :comment, App.Comment
    belongs_to :assignment, App.Assignment
    belongs_to :student, App.Student
    belongs_to :teacher, App.Teacher

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:mark, :comment_id, :assignment_id, :student_id, :teacher_id])
    |> validate_required([:mark, :comment_id, :assignment_id, :student_id, :teacher_id])
  end
end
