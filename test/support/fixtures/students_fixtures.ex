defmodule App.StudentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Students` context.
  """

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{

      })
      |> App.Students.create_student()

    student
  end
end
