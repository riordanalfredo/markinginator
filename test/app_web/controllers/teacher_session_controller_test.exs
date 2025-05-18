defmodule AppWeb.TeacherSessionControllerTest do
  use AppWeb.ConnCase, async: true

  import App.TeachersFixtures

  setup do
    %{teacher: teacher_fixture()}
  end

  describe "POST /teachers/log_in" do
    test "logs the teacher in", %{conn: conn, teacher: teacher} do
      conn =
        post(conn, ~p"/teachers/log_in", %{
          "teacher" => %{"email" => teacher.email, "password" => valid_teacher_password()}
        })

      assert get_session(conn, :teacher_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ teacher.email
      assert response =~ ~p"/teachers/settings"
      assert response =~ ~p"/teachers/log_out"
    end

    test "logs the teacher in with remember me", %{conn: conn, teacher: teacher} do
      conn =
        post(conn, ~p"/teachers/log_in", %{
          "teacher" => %{
            "email" => teacher.email,
            "password" => valid_teacher_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_app_web_teacher_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the teacher in with return to", %{conn: conn, teacher: teacher} do
      conn =
        conn
        |> init_test_session(teacher_return_to: "/foo/bar")
        |> post(~p"/teachers/log_in", %{
          "teacher" => %{
            "email" => teacher.email,
            "password" => valid_teacher_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, teacher: teacher} do
      conn =
        conn
        |> post(~p"/teachers/log_in", %{
          "_action" => "registered",
          "teacher" => %{
            "email" => teacher.email,
            "password" => valid_teacher_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, teacher: teacher} do
      conn =
        conn
        |> post(~p"/teachers/log_in", %{
          "_action" => "password_updated",
          "teacher" => %{
            "email" => teacher.email,
            "password" => valid_teacher_password()
          }
        })

      assert redirected_to(conn) == ~p"/teachers/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/teachers/log_in", %{
          "teacher" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/teachers/log_in"
    end
  end

  describe "DELETE /teachers/log_out" do
    test "logs the teacher out", %{conn: conn, teacher: teacher} do
      conn = conn |> log_in_teacher(teacher) |> delete(~p"/teachers/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :teacher_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the teacher is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/teachers/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :teacher_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
