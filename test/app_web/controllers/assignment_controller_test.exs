defmodule AppWeb.AssignmentControllerTest do
  use AppWeb.ConnCase

  import App.AssignmentsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all assignments", %{conn: conn} do
      conn = get(conn, ~p"/assignments")
      assert html_response(conn, 200) =~ "Listing Assignments"
    end
  end

  describe "new assignment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/assignments/new")
      assert html_response(conn, 200) =~ "New Assignment"
    end
  end

  describe "create assignment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/assignments", assignment: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/assignments/#{id}"

      conn = get(conn, ~p"/assignments/#{id}")
      assert html_response(conn, 200) =~ "Assignment #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/assignments", assignment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Assignment"
    end
  end

  describe "edit assignment" do
    setup [:create_assignment]

    test "renders form for editing chosen assignment", %{conn: conn, assignment: assignment} do
      conn = get(conn, ~p"/assignments/#{assignment}/edit")
      assert html_response(conn, 200) =~ "Edit Assignment"
    end
  end

  describe "update assignment" do
    setup [:create_assignment]

    test "redirects when data is valid", %{conn: conn, assignment: assignment} do
      conn = put(conn, ~p"/assignments/#{assignment}", assignment: @update_attrs)
      assert redirected_to(conn) == ~p"/assignments/#{assignment}"

      conn = get(conn, ~p"/assignments/#{assignment}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, assignment: assignment} do
      conn = put(conn, ~p"/assignments/#{assignment}", assignment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Assignment"
    end
  end

  describe "delete assignment" do
    setup [:create_assignment]

    test "deletes chosen assignment", %{conn: conn, assignment: assignment} do
      conn = delete(conn, ~p"/assignments/#{assignment}")
      assert redirected_to(conn) == ~p"/assignments"

      assert_error_sent 404, fn ->
        get(conn, ~p"/assignments/#{assignment}")
      end
    end
  end

  defp create_assignment(_) do
    assignment = assignment_fixture()
    %{assignment: assignment}
  end
end
