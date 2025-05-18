defmodule AppWeb.AssignmentHTML do
  use AppWeb, :html

  embed_templates "assignment_html/*"

  @doc """
  Renders a assignment form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def assignment_form(assigns)
end
