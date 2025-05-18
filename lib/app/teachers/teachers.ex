defmodule App.Teachers do
  @moduledoc """
  The Teachers context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Teachers.{Teacher, TeacherToken, TeacherNotifier}

  ## Database getters

  @doc """
  Gets a teacher by email.

  ## Examples

      iex> get_teacher_by_email("foo@example.com")
      %Teacher{}

      iex> get_teacher_by_email("unknown@example.com")
      nil

  """
  def get_teacher_by_email(email) when is_binary(email) do
    Repo.get_by(Teacher, email: email)
  end

  @doc """
  Gets a teacher by email and password.

  ## Examples

      iex> get_teacher_by_email_and_password("foo@example.com", "correct_password")
      %Teacher{}

      iex> get_teacher_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_teacher_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    teacher = Repo.get_by(Teacher, email: email)
    if Teacher.valid_password?(teacher, password), do: teacher
  end

  @doc """
  Gets a single teacher.

  Raises `Ecto.NoResultsError` if the Teacher does not exist.

  ## Examples

      iex> get_teacher!(123)
      %Teacher{}

      iex> get_teacher!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher!(id), do: Repo.get!(Teacher, id)

  ## Teacher registration

  @doc """
  Registers a teacher.

  ## Examples

      iex> register_teacher(%{field: value})
      {:ok, %Teacher{}}

      iex> register_teacher(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_teacher(attrs) do
    %Teacher{}
    |> Teacher.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher changes.

  ## Examples

      iex> change_teacher_registration(teacher)
      %Ecto.Changeset{data: %Teacher{}}

  """
  def change_teacher_registration(%Teacher{} = teacher, attrs \\ %{}) do
    Teacher.registration_changeset(teacher, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the teacher email.

  ## Examples

      iex> change_teacher_email(teacher)
      %Ecto.Changeset{data: %Teacher{}}

  """
  def change_teacher_email(teacher, attrs \\ %{}) do
    Teacher.email_changeset(teacher, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_teacher_email(teacher, "valid password", %{email: ...})
      {:ok, %Teacher{}}

      iex> apply_teacher_email(teacher, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_teacher_email(teacher, password, attrs) do
    teacher
    |> Teacher.email_changeset(attrs)
    |> Teacher.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the teacher email using the given token.

  If the token matches, the teacher email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_teacher_email(teacher, token) do
    context = "change:#{teacher.email}"

    with {:ok, query} <- TeacherToken.verify_change_email_token_query(token, context),
         %TeacherToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(teacher_email_multi(teacher, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp teacher_email_multi(teacher, email, context) do
    changeset =
      teacher
      |> Teacher.email_changeset(%{email: email})
      |> Teacher.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:teacher, changeset)
    |> Ecto.Multi.delete_all(:tokens, TeacherToken.by_teacher_and_contexts_query(teacher, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given teacher.

  ## Examples

      iex> deliver_teacher_update_email_instructions(teacher, current_email, &url(~p"/teachers/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_teacher_update_email_instructions(%Teacher{} = teacher, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, teacher_token} = TeacherToken.build_email_token(teacher, "change:#{current_email}")

    Repo.insert!(teacher_token)
    TeacherNotifier.deliver_update_email_instructions(teacher, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the teacher password.

  ## Examples

      iex> change_teacher_password(teacher)
      %Ecto.Changeset{data: %Teacher{}}

  """
  def change_teacher_password(teacher, attrs \\ %{}) do
    Teacher.password_changeset(teacher, attrs, hash_password: false)
  end

  @doc """
  Updates the teacher password.

  ## Examples

      iex> update_teacher_password(teacher, "valid password", %{password: ...})
      {:ok, %Teacher{}}

      iex> update_teacher_password(teacher, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher_password(teacher, password, attrs) do
    changeset =
      teacher
      |> Teacher.password_changeset(attrs)
      |> Teacher.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:teacher, changeset)
    |> Ecto.Multi.delete_all(:tokens, TeacherToken.by_teacher_and_contexts_query(teacher, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{teacher: teacher}} -> {:ok, teacher}
      {:error, :teacher, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_teacher_session_token(teacher) do
    {token, teacher_token} = TeacherToken.build_session_token(teacher)
    Repo.insert!(teacher_token)
    token
  end

  @doc """
  Gets the teacher with the given signed token.
  """
  def get_teacher_by_session_token(token) do
    {:ok, query} = TeacherToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_teacher_session_token(token) do
    Repo.delete_all(TeacherToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given teacher.

  ## Examples

      iex> deliver_teacher_confirmation_instructions(teacher, &url(~p"/teachers/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_teacher_confirmation_instructions(confirmed_teacher, &url(~p"/teachers/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_teacher_confirmation_instructions(%Teacher{} = teacher, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if teacher.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, teacher_token} = TeacherToken.build_email_token(teacher, "confirm")
      Repo.insert!(teacher_token)
      TeacherNotifier.deliver_confirmation_instructions(teacher, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a teacher by the given token.

  If the token matches, the teacher account is marked as confirmed
  and the token is deleted.
  """
  def confirm_teacher(token) do
    with {:ok, query} <- TeacherToken.verify_email_token_query(token, "confirm"),
         %Teacher{} = teacher <- Repo.one(query),
         {:ok, %{teacher: teacher}} <- Repo.transaction(confirm_teacher_multi(teacher)) do
      {:ok, teacher}
    else
      _ -> :error
    end
  end

  defp confirm_teacher_multi(teacher) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:teacher, Teacher.confirm_changeset(teacher))
    |> Ecto.Multi.delete_all(:tokens, TeacherToken.by_teacher_and_contexts_query(teacher, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given teacher.

  ## Examples

      iex> deliver_teacher_reset_password_instructions(teacher, &url(~p"/teachers/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_teacher_reset_password_instructions(%Teacher{} = teacher, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, teacher_token} = TeacherToken.build_email_token(teacher, "reset_password")
    Repo.insert!(teacher_token)
    TeacherNotifier.deliver_reset_password_instructions(teacher, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the teacher by reset password token.

  ## Examples

      iex> get_teacher_by_reset_password_token("validtoken")
      %Teacher{}

      iex> get_teacher_by_reset_password_token("invalidtoken")
      nil

  """
  def get_teacher_by_reset_password_token(token) do
    with {:ok, query} <- TeacherToken.verify_email_token_query(token, "reset_password"),
         %Teacher{} = teacher <- Repo.one(query) do
      teacher
    else
      _ -> nil
    end
  end

  @doc """
  Resets the teacher password.

  ## Examples

      iex> reset_teacher_password(teacher, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Teacher{}}

      iex> reset_teacher_password(teacher, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_teacher_password(teacher, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:teacher, Teacher.password_changeset(teacher, attrs))
    |> Ecto.Multi.delete_all(:tokens, TeacherToken.by_teacher_and_contexts_query(teacher, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{teacher: teacher}} -> {:ok, teacher}
      {:error, :teacher, changeset, _} -> {:error, changeset}
    end
  end
end
