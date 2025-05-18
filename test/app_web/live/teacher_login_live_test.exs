defmodule AppWeb.TeacherLoginLiveTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import App.TeachersFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/teachers/log_in")

      assert html =~ "Log in"
      assert html =~ "Register"
      assert html =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_teacher(teacher_fixture())
        |> live(~p"/teachers/log_in")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "teacher login" do
    test "redirects if teacher login with valid credentials", %{conn: conn} do
      password = "123456789abcd"
      teacher = teacher_fixture(%{password: password})

      {:ok, lv, _html} = live(conn, ~p"/teachers/log_in")

      form =
        form(lv, "#login_form", teacher: %{email: teacher.email, password: password, remember_me: true})

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/teachers/log_in")

      form =
        form(lv, "#login_form",
          teacher: %{email: "test@email.com", password: "123456", remember_me: true}
        )

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"

      assert redirected_to(conn) == "/teachers/log_in"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Register button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/log_in")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign up")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/teachers/register")

      assert login_html =~ "Register"
    end

    test "redirects to forgot password page when the Forgot Password button is clicked", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/teachers/log_in")

      {:ok, conn} =
        lv
        |> element(~s|main a:fl-contains("Forgot your password?")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/teachers/reset_password")

      assert conn.resp_body =~ "Forgot your password?"
    end
  end
end
