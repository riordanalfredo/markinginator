defmodule AppWeb.AssignmentController do
  use AppWeb, :controller

  alias App.Assignments
  alias App.Assignments.Assignment

  def index(conn, _params) do
    assignments = Assignments.list_assignments()
    render(conn, :index, assignments: assignments)
  end

  def new(conn, _params) do
    changeset = Assignments.change_assignment(%Assignment{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"assignment" => assignment_params}) do
    case Assignments.create_assignment(assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment created successfully.")
        |> redirect(to: ~p"/assignments/#{assignment}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    render(conn, :show, assignment: assignment)
  end

  def edit(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    changeset = Assignments.change_assignment(assignment)
    render(conn, :edit, assignment: assignment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "assignment" => assignment_params}) do
    assignment = Assignments.get_assignment!(id)

    case Assignments.update_assignment(assignment, assignment_params) do
      {:ok, assignment} ->
        conn
        |> put_flash(:info, "Assignment updated successfully.")
        |> redirect(to: ~p"/assignments/#{assignment}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, assignment: assignment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    {:ok, _assignment} = Assignments.delete_assignment(assignment)

    conn
    |> put_flash(:info, "Assignment deleted successfully.")
    |> redirect(to: ~p"/assignments")
  end
end
