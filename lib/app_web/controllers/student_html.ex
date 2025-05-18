defmodule AppWeb.StudentHTML do
  use AppWeb, :html

  embed_templates "student_html/*"

  @doc """
  Renders a student form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def student_form(assigns)
end
