defmodule AppWeb.FeedbackControllerTest do
  use AppWeb.ConnCase

  import App.FeedbacksFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all feedbacks", %{conn: conn} do
      conn = get(conn, ~p"/feedbacks")
      assert html_response(conn, 200) =~ "Listing Feedbacks"
    end
  end

  describe "new feedback" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/feedbacks/new")
      assert html_response(conn, 200) =~ "New Feedback"
    end
  end

  describe "create feedback" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/feedbacks", feedback: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/feedbacks/#{id}"

      conn = get(conn, ~p"/feedbacks/#{id}")
      assert html_response(conn, 200) =~ "Feedback #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/feedbacks", feedback: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Feedback"
    end
  end

  describe "edit feedback" do
    setup [:create_feedback]

    test "renders form for editing chosen feedback", %{conn: conn, feedback: feedback} do
      conn = get(conn, ~p"/feedbacks/#{feedback}/edit")
      assert html_response(conn, 200) =~ "Edit Feedback"
    end
  end

  describe "update feedback" do
    setup [:create_feedback]

    test "redirects when data is valid", %{conn: conn, feedback: feedback} do
      conn = put(conn, ~p"/feedbacks/#{feedback}", feedback: @update_attrs)
      assert redirected_to(conn) == ~p"/feedbacks/#{feedback}"

      conn = get(conn, ~p"/feedbacks/#{feedback}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, feedback: feedback} do
      conn = put(conn, ~p"/feedbacks/#{feedback}", feedback: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Feedback"
    end
  end

  describe "delete feedback" do
    setup [:create_feedback]

    test "deletes chosen feedback", %{conn: conn, feedback: feedback} do
      conn = delete(conn, ~p"/feedbacks/#{feedback}")
      assert redirected_to(conn) == ~p"/feedbacks"

      assert_error_sent 404, fn ->
        get(conn, ~p"/feedbacks/#{feedback}")
      end
    end
  end

  defp create_feedback(_) do
    feedback = feedback_fixture()
    %{feedback: feedback}
  end
end
