defmodule App.FeedbacksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Feedbacks` context.
  """

  @doc """
  Generate a feedback.
  """
  def feedback_fixture(attrs \\ %{}) do
    {:ok, feedback} =
      attrs
      |> Enum.into(%{

      })
      |> App.Feedbacks.create_feedback()

    feedback
  end
end
