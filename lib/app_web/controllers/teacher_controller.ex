defmodule AppWeb.TeacherController do
  use AppWeb, :controller

  alias App.Teachers
  alias App.Teachers.Teacher

  def index(conn, _params) do
    teachers = Teachers.list_teachers()
    render(conn, :index, teachers: teachers)
  end

  def new(conn, _params) do
    changeset = Teachers.change_teacher(%Teacher{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"teacher" => teacher_params}) do
    case Teachers.create_teacher(teacher_params) do
      {:ok, teacher} ->
        conn
        |> put_flash(:info, "Teacher created successfully.")
        |> redirect(to: ~p"/teachers/#{teacher}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    teacher = Teachers.get_teacher!(id)
    render(conn, :show, teacher: teacher)
  end

  def edit(conn, %{"id" => id}) do
    teacher = Teachers.get_teacher!(id)
    changeset = Teachers.change_teacher(teacher)
    render(conn, :edit, teacher: teacher, changeset: changeset)
  end

  def update(conn, %{"id" => id, "teacher" => teacher_params}) do
    teacher = Teachers.get_teacher!(id)

    case Teachers.update_teacher(teacher, teacher_params) do
      {:ok, teacher} ->
        conn
        |> put_flash(:info, "Teacher updated successfully.")
        |> redirect(to: ~p"/teachers/#{teacher}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, teacher: teacher, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    teacher = Teachers.get_teacher!(id)
    {:ok, _teacher} = Teachers.delete_teacher(teacher)

    conn
    |> put_flash(:info, "Teacher deleted successfully.")
    |> redirect(to: ~p"/teachers")
  end
end
