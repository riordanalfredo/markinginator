defmodule App.AssignmentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Assignments` context.
  """

  @doc """
  Generate a assignment.
  """
  def assignment_fixture(attrs \\ %{}) do
    {:ok, assignment} =
      attrs
      |> Enum.into(%{

      })
      |> App.Assignments.create_assignment()

    assignment
  end
end
