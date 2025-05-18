defmodule AppWeb.TeacherForgotPasswordLiveTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import App.TeachersFixtures

  alias App.Teachers
  alias App.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/teachers/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/teachers/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/teachers/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_teacher(teacher_fixture())
        |> live(~p"/teachers/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, teacher: teacher} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", teacher: %{"email" => teacher.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Teachers.TeacherToken, teacher_id: teacher.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", teacher: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Teachers.TeacherToken) == []
    end
  end
end
