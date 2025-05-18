defmodule App.TeachersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Teachers` context.
  """

  def unique_teacher_email, do: "teacher#{System.unique_integer()}@example.com"
  def valid_teacher_password, do: "hello world!"

  def valid_teacher_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_teacher_email(),
      password: valid_teacher_password()
    })
  end

  def teacher_fixture(attrs \\ %{}) do
    {:ok, teacher} =
      attrs
      |> valid_teacher_attributes()
      |> App.Teachers.register_teacher()

    teacher
  end

  def extract_teacher_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
