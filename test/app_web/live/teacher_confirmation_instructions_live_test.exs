defmodule AppWeb.TeacherConfirmationInstructionsLiveTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import App.TeachersFixtures

  alias App.Teachers
  alias App.Repo

  setup do
    %{teacher: teacher_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/teachers/confirm")
      assert html =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, teacher: teacher} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", teacher: %{email: teacher.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Teachers.TeacherToken, teacher_id: teacher.id).context == "confirm"
    end

    test "does not send confirmation token if teacher is confirmed", %{conn: conn, teacher: teacher} do
      Repo.update!(Teachers.Teacher.confirm_changeset(teacher))

      {:ok, lv, _html} = live(conn, ~p"/teachers/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", teacher: %{email: teacher.email})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Teachers.TeacherToken, teacher_id: teacher.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/confirm")

      {:ok, conn} =
        lv
        |> form("#resend_confirmation_form", teacher: %{email: "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Teachers.TeacherToken) == []
    end
  end
end
