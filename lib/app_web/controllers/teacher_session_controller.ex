defmodule AppWeb.TeacherSessionController do
  use AppWeb, :controller

  alias App.Teachers
  alias AppWeb.TeacherAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:teacher_return_to, ~p"/teachers/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"teacher" => teacher_params}, info) do
    %{"email" => email, "password" => password} = teacher_params

    if teacher = Teachers.get_teacher_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> TeacherAuth.log_in_teacher(teacher, teacher_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/teachers/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> TeacherAuth.log_out_teacher()
  end
end
