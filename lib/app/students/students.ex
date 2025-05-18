defmodule App.Students do
  @moduledoc """
  The Students context.
  """

  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Students.Student

  @doc """
  Returns the list of students.

  ## Examples

      iex> list_students()
      [%Student{}, ...]

  """
  def list_students do
    Repo.all(Student)
  end

  @doc """
  Gets a single student.

  Raises if the Student does not exist.

  ## Examples

      iex> get_student!(123)
      %Student{}

  """
  def get_student!(id), do: Repo.get!(Student, id)

  @doc """
  Creates a student.

  ## Examples

      iex> create_student(%{field: value})
      {:ok, %Student{}}

      iex> create_student(%{field: bad_value})
      {:error, ...}

  """
  def create_student(attrs \\ %{}) do
    %Student{}
      |> Student.changeset(attrs)
      |> Repo.insert()
  end

  @doc """
  Updates a student.

  ## Examples

      iex> update_student(student, %{field: new_value})
      {:ok, %Student{}}

      iex> update_student(student, %{field: bad_value})
      {:error, ...}

  """
  def update_student(%Student{} = student, attrs) do
    student
    |> Student.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Student.

  ## Examples

      iex> delete_student(student)
      {:ok, %Student{}}

      iex> delete_student(student)
      {:error, ...}

  """
  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  @doc """
  Returns a data structure for tracking student changes.

  ## Examples

      iex> change_student(student)
      %Student{...}

  """
  def change_student(%Student{} = student, attrs \\ %{}) do
    Student.changeset(student, attrs)
  end
end
