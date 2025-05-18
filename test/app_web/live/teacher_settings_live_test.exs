defmodule AppWeb.TeacherSettingsLiveTest do
  use AppWeb.ConnCase, async: true

  alias App.Teachers
  import Phoenix.LiveViewTest
  import App.TeachersFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_teacher(teacher_fixture())
        |> live(~p"/teachers/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if teacher is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/teachers/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/teachers/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_teacher_password()
      teacher = teacher_fixture(%{password: password})
      %{conn: log_in_teacher(conn, teacher), teacher: teacher, password: password}
    end

    test "updates the teacher email", %{conn: conn, password: password, teacher: teacher} do
      new_email = unique_teacher_email()

      {:ok, lv, _html} = live(conn, ~p"/teachers/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "teacher" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Teachers.get_teacher_by_email(teacher.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "teacher" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, teacher: teacher} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "teacher" => %{"email" => teacher.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_teacher_password()
      teacher = teacher_fixture(%{password: password})
      %{conn: log_in_teacher(conn, teacher), teacher: teacher, password: password}
    end

    test "updates the teacher password", %{conn: conn, teacher: teacher, password: password} do
      new_password = valid_teacher_password()

      {:ok, lv, _html} = live(conn, ~p"/teachers/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "teacher" => %{
            "email" => teacher.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/teachers/settings"

      assert get_session(new_password_conn, :teacher_token) != get_session(conn, :teacher_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Teachers.get_teacher_by_email_and_password(teacher.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "teacher" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/teachers/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "teacher" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      teacher = teacher_fixture()
      email = unique_teacher_email()

      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_update_email_instructions(%{teacher | email: email}, teacher.email, url)
        end)

      %{conn: log_in_teacher(conn, teacher), token: token, email: email, teacher: teacher}
    end

    test "updates the teacher email once", %{conn: conn, teacher: teacher, token: token, email: email} do
      {:error, redirect} = live(conn, ~p"/teachers/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/teachers/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Teachers.get_teacher_by_email(teacher.email)
      assert Teachers.get_teacher_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/teachers/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/teachers/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, teacher: teacher} do
      {:error, redirect} = live(conn, ~p"/teachers/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/teachers/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Teachers.get_teacher_by_email(teacher.email)
    end

    test "redirects if teacher is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/teachers/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/teachers/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
