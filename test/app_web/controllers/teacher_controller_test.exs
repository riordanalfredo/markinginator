defmodule AppWeb.TeacherControllerTest do
  use AppWeb.ConnCase

  import App.TeachersFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all teachers", %{conn: conn} do
      conn = get(conn, ~p"/teachers")
      assert html_response(conn, 200) =~ "Listing Teachers"
    end
  end

  describe "new teacher" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/teachers/new")
      assert html_response(conn, 200) =~ "New Teacher"
    end
  end

  describe "create teacher" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/teachers", teacher: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/teachers/#{id}"

      conn = get(conn, ~p"/teachers/#{id}")
      assert html_response(conn, 200) =~ "Teacher #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/teachers", teacher: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Teacher"
    end
  end

  describe "edit teacher" do
    setup [:create_teacher]

    test "renders form for editing chosen teacher", %{conn: conn, teacher: teacher} do
      conn = get(conn, ~p"/teachers/#{teacher}/edit")
      assert html_response(conn, 200) =~ "Edit Teacher"
    end
  end

  describe "update teacher" do
    setup [:create_teacher]

    test "redirects when data is valid", %{conn: conn, teacher: teacher} do
      conn = put(conn, ~p"/teachers/#{teacher}", teacher: @update_attrs)
      assert redirected_to(conn) == ~p"/teachers/#{teacher}"

      conn = get(conn, ~p"/teachers/#{teacher}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, teacher: teacher} do
      conn = put(conn, ~p"/teachers/#{teacher}", teacher: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Teacher"
    end
  end

  describe "delete teacher" do
    setup [:create_teacher]

    test "deletes chosen teacher", %{conn: conn, teacher: teacher} do
      conn = delete(conn, ~p"/teachers/#{teacher}")
      assert redirected_to(conn) == ~p"/teachers"

      assert_error_sent 404, fn ->
        get(conn, ~p"/teachers/#{teacher}")
      end
    end
  end

  defp create_teacher(_) do
    teacher = teacher_fixture()
    %{teacher: teacher}
  end
end
