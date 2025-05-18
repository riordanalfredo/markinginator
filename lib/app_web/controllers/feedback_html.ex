defmodule AppWeb.FeedbackHTML do
  use AppWeb, :html

  embed_templates "feedback_html/*"

  @doc """
  Renders a feedback form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def feedback_form(assigns)
end
