defmodule AppWeb.FeedbackController do
  use AppWeb, :controller

  alias App.Feedbacks
  alias App.Feedbacks.Feedback

  def index(conn, _params) do
    feedbacks = Feedbacks.list_feedbacks()
    render(conn, :index, feedbacks: feedbacks)
  end

  def new(conn, _params) do
    changeset = Feedbacks.change_feedback(%Feedback{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"feedback" => feedback_params}) do
    case Feedbacks.create_feedback(feedback_params) do
      {:ok, feedback} ->
        conn
        |> put_flash(:info, "Feedback created successfully.")
        |> redirect(to: ~p"/feedbacks/#{feedback}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    feedback = Feedbacks.get_feedback!(id)
    render(conn, :show, feedback: feedback)
  end

  def edit(conn, %{"id" => id}) do
    feedback = Feedbacks.get_feedback!(id)
    changeset = Feedbacks.change_feedback(feedback)
    render(conn, :edit, feedback: feedback, changeset: changeset)
  end

  def update(conn, %{"id" => id, "feedback" => feedback_params}) do
    feedback = Feedbacks.get_feedback!(id)

    case Feedbacks.update_feedback(feedback, feedback_params) do
      {:ok, feedback} ->
        conn
        |> put_flash(:info, "Feedback updated successfully.")
        |> redirect(to: ~p"/feedbacks/#{feedback}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, feedback: feedback, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    feedback = Feedbacks.get_feedback!(id)
    {:ok, _feedback} = Feedbacks.delete_feedback(feedback)

    conn
    |> put_flash(:info, "Feedback deleted successfully.")
    |> redirect(to: ~p"/feedbacks")
  end
end
