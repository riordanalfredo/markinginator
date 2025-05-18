defmodule App.TeachersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Teachers` context.
  """

  @doc """
  Generate a teacher.
  """
  def teacher_fixture(attrs \\ %{}) do
    {:ok, teacher} =
      attrs
      |> Enum.into(%{

      })
      |> App.Teachers.create_teacher()

    teacher
  end
end
