defmodule AppWeb.TeacherAuthTest do
  use AppWeb.ConnCase, async: true

  alias Phoenix.LiveView
  alias App.Teachers
  alias AppWeb.TeacherAuth
  import App.TeachersFixtures

  @remember_me_cookie "_app_web_teacher_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, AppWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{teacher: teacher_fixture(), conn: conn}
  end

  describe "log_in_teacher/3" do
    test "stores the teacher token in the session", %{conn: conn, teacher: teacher} do
      conn = TeacherAuth.log_in_teacher(conn, teacher)
      assert token = get_session(conn, :teacher_token)
      assert get_session(conn, :live_socket_id) == "teachers_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == ~p"/"
      assert Teachers.get_teacher_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, teacher: teacher} do
      conn = conn |> put_session(:to_be_removed, "value") |> TeacherAuth.log_in_teacher(teacher)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, teacher: teacher} do
      conn = conn |> put_session(:teacher_return_to, "/hello") |> TeacherAuth.log_in_teacher(teacher)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, teacher: teacher} do
      conn = conn |> fetch_cookies() |> TeacherAuth.log_in_teacher(teacher, %{"remember_me" => "true"})
      assert get_session(conn, :teacher_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :teacher_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_teacher/1" do
    test "erases session and cookies", %{conn: conn, teacher: teacher} do
      teacher_token = Teachers.generate_teacher_session_token(teacher)

      conn =
        conn
        |> put_session(:teacher_token, teacher_token)
        |> put_req_cookie(@remember_me_cookie, teacher_token)
        |> fetch_cookies()
        |> TeacherAuth.log_out_teacher()

      refute get_session(conn, :teacher_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
      refute Teachers.get_teacher_by_session_token(teacher_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "teachers_sessions:abcdef-token"
      AppWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> TeacherAuth.log_out_teacher()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if teacher is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> TeacherAuth.log_out_teacher()
      refute get_session(conn, :teacher_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "fetch_current_teacher/2" do
    test "authenticates teacher from session", %{conn: conn, teacher: teacher} do
      teacher_token = Teachers.generate_teacher_session_token(teacher)
      conn = conn |> put_session(:teacher_token, teacher_token) |> TeacherAuth.fetch_current_teacher([])
      assert conn.assigns.current_teacher.id == teacher.id
    end

    test "authenticates teacher from cookies", %{conn: conn, teacher: teacher} do
      logged_in_conn =
        conn |> fetch_cookies() |> TeacherAuth.log_in_teacher(teacher, %{"remember_me" => "true"})

      teacher_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> TeacherAuth.fetch_current_teacher([])

      assert conn.assigns.current_teacher.id == teacher.id
      assert get_session(conn, :teacher_token) == teacher_token

      assert get_session(conn, :live_socket_id) ==
               "teachers_sessions:#{Base.url_encode64(teacher_token)}"
    end

    test "does not authenticate if data is missing", %{conn: conn, teacher: teacher} do
      _ = Teachers.generate_teacher_session_token(teacher)
      conn = TeacherAuth.fetch_current_teacher(conn, [])
      refute get_session(conn, :teacher_token)
      refute conn.assigns.current_teacher
    end
  end

  describe "on_mount :mount_current_teacher" do
    test "assigns current_teacher based on a valid teacher_token", %{conn: conn, teacher: teacher} do
      teacher_token = Teachers.generate_teacher_session_token(teacher)
      session = conn |> put_session(:teacher_token, teacher_token) |> get_session()

      {:cont, updated_socket} =
        TeacherAuth.on_mount(:mount_current_teacher, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_teacher.id == teacher.id
    end

    test "assigns nil to current_teacher assign if there isn't a valid teacher_token", %{conn: conn} do
      teacher_token = "invalid_token"
      session = conn |> put_session(:teacher_token, teacher_token) |> get_session()

      {:cont, updated_socket} =
        TeacherAuth.on_mount(:mount_current_teacher, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_teacher == nil
    end

    test "assigns nil to current_teacher assign if there isn't a teacher_token", %{conn: conn} do
      session = conn |> get_session()

      {:cont, updated_socket} =
        TeacherAuth.on_mount(:mount_current_teacher, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_teacher == nil
    end
  end

  describe "on_mount :ensure_authenticated" do
    test "authenticates current_teacher based on a valid teacher_token", %{conn: conn, teacher: teacher} do
      teacher_token = Teachers.generate_teacher_session_token(teacher)
      session = conn |> put_session(:teacher_token, teacher_token) |> get_session()

      {:cont, updated_socket} =
        TeacherAuth.on_mount(:ensure_authenticated, %{}, session, %LiveView.Socket{})

      assert updated_socket.assigns.current_teacher.id == teacher.id
    end

    test "redirects to login page if there isn't a valid teacher_token", %{conn: conn} do
      teacher_token = "invalid_token"
      session = conn |> put_session(:teacher_token, teacher_token) |> get_session()

      socket = %LiveView.Socket{
        endpoint: AppWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = TeacherAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_teacher == nil
    end

    test "redirects to login page if there isn't a teacher_token", %{conn: conn} do
      session = conn |> get_session()

      socket = %LiveView.Socket{
        endpoint: AppWeb.Endpoint,
        assigns: %{__changed__: %{}, flash: %{}}
      }

      {:halt, updated_socket} = TeacherAuth.on_mount(:ensure_authenticated, %{}, session, socket)
      assert updated_socket.assigns.current_teacher == nil
    end
  end

  describe "on_mount :redirect_if_teacher_is_authenticated" do
    test "redirects if there is an authenticated  teacher ", %{conn: conn, teacher: teacher} do
      teacher_token = Teachers.generate_teacher_session_token(teacher)
      session = conn |> put_session(:teacher_token, teacher_token) |> get_session()

      assert {:halt, _updated_socket} =
               TeacherAuth.on_mount(
                 :redirect_if_teacher_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end

    test "doesn't redirect if there is no authenticated teacher", %{conn: conn} do
      session = conn |> get_session()

      assert {:cont, _updated_socket} =
               TeacherAuth.on_mount(
                 :redirect_if_teacher_is_authenticated,
                 %{},
                 session,
                 %LiveView.Socket{}
               )
    end
  end

  describe "redirect_if_teacher_is_authenticated/2" do
    test "redirects if teacher is authenticated", %{conn: conn, teacher: teacher} do
      conn = conn |> assign(:current_teacher, teacher) |> TeacherAuth.redirect_if_teacher_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/"
    end

    test "does not redirect if teacher is not authenticated", %{conn: conn} do
      conn = TeacherAuth.redirect_if_teacher_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_teacher/2" do
    test "redirects if teacher is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> TeacherAuth.require_authenticated_teacher([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/teachers/log_in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> TeacherAuth.require_authenticated_teacher([])

      assert halted_conn.halted
      assert get_session(halted_conn, :teacher_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> TeacherAuth.require_authenticated_teacher([])

      assert halted_conn.halted
      assert get_session(halted_conn, :teacher_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> TeacherAuth.require_authenticated_teacher([])

      assert halted_conn.halted
      refute get_session(halted_conn, :teacher_return_to)
    end

    test "does not redirect if teacher is authenticated", %{conn: conn, teacher: teacher} do
      conn = conn |> assign(:current_teacher, teacher) |> TeacherAuth.require_authenticated_teacher([])
      refute conn.halted
      refute conn.status
    end
  end
end
