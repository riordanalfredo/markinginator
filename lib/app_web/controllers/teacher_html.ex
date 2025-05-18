defmodule AppWeb.TeacherHTML do
  use AppWeb, :html

  embed_templates "teacher_html/*"

  @doc """
  Renders a teacher form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def teacher_form(assigns)
end
