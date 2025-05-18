defmodule App.Feedbacks.Feedback do

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


  @moduledoc """
  The Feedbacks context.
  """
  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Feedbacks.Feedback

  @doc """
  Returns the list of feedbacks.

  ## Examples

      iex> list_feedbacks()
      [%Feedback{}, ...]

  """
  def list_feedbacks do
    raise "TODO"
  end

  @doc """
  Gets a single feedback.

  Raises if the Feedback does not exist.

  ## Examples

      iex> get_feedback!(123)
      %Feedback{}

  """
  def get_feedback!(id), do: raise "TODO"

  @doc """
  Creates a feedback.

  ## Examples

      iex> create_feedback(%{field: value})
      {:ok, %Feedback{}}

      iex> create_feedback(%{field: bad_value})
      {:error, ...}

  """
  def create_feedback(attrs \\ %{}) do
    raise "TODO"
  end

  @doc """
  Updates a feedback.

  ## Examples

      iex> update_feedback(feedback, %{field: new_value})
      {:ok, %Feedback{}}

      iex> update_feedback(feedback, %{field: bad_value})
      {:error, ...}

  """
  def update_feedback(%Feedback{} = feedback, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Feedback.

  ## Examples

      iex> delete_feedback(feedback)
      {:ok, %Feedback{}}

      iex> delete_feedback(feedback)
      {:error, ...}

  """
  def delete_feedback(%Feedback{} = feedback) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking feedback changes.

  ## Examples

      iex> change_feedback(feedback)
      %Todo{...}

  """
  def change_feedback(%Feedback{} = feedback, _attrs \\ %{}) do
    raise "TODO"
  end
end
