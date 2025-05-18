defmodule App.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Assignments.Assignment

  @doc """
  Returns the list of assignments.

  ## Examples

      iex> list_assignments()
      [%Assignment{}, ...]

  """
  def list_assignments do
    raise "TODO"
  end

  @doc """
  Gets a single assignment.

  Raises if the Assignment does not exist.

  ## Examples

      iex> get_assignment!(123)
      %Assignment{}

  """
  def get_assignment!(id), do: raise "TODO"

  @doc """
  Creates a assignment.

  ## Examples

      iex> create_assignment(%{field: value})
      {:ok, %Assignment{}}

      iex> create_assignment(%{field: bad_value})
      {:error, ...}

  """
  def create_assignment(attrs \\ %{}) do
    raise "TODO"
  end

  @doc """
  Updates a assignment.

  ## Examples

      iex> update_assignment(assignment, %{field: new_value})
      {:ok, %Assignment{}}

      iex> update_assignment(assignment, %{field: bad_value})
      {:error, ...}

  """
  def update_assignment(%Assignment{} = assignment, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Assignment.

  ## Examples

      iex> delete_assignment(assignment)
      {:ok, %Assignment{}}

      iex> delete_assignment(assignment)
      {:error, ...}

  """
  def delete_assignment(%Assignment{} = assignment) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking assignment changes.

  ## Examples

      iex> change_assignment(assignment)
      %Todo{...}

  """
  def change_assignment(%Assignment{} = assignment, _attrs \\ %{}) do
    raise "TODO"
  end
end
