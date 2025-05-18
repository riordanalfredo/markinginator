defmodule AppWeb.TeacherConfirmationLiveTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import App.TeachersFixtures

  alias App.Teachers
  alias App.Repo

  setup do
    %{teacher: teacher_fixture()}
  end

  describe "Confirm teacher" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/teachers/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, teacher: teacher} do
      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_confirmation_instructions(teacher, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/teachers/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Teacher confirmed successfully"

      assert Teachers.get_teacher!(teacher.id).confirmed_at
      refute get_session(conn, :teacher_token)
      assert Repo.all(Teachers.TeacherToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/teachers/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Teacher confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_teacher(teacher)

      {:ok, lv, _html} = live(conn, ~p"/teachers/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, teacher: teacher} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Teacher confirmation link is invalid or it has expired"

      refute Teachers.get_teacher!(teacher.id).confirmed_at
    end
  end
end
