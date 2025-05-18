defmodule App.Teachers.TeacherNotifier do
  import Swoosh.Email

  alias App.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"App", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(teacher, url) do
    deliver(teacher.email, "Confirmation instructions", """

    ==============================

    Hi #{teacher.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a teacher password.
  """
  def deliver_reset_password_instructions(teacher, url) do
    deliver(teacher.email, "Reset password instructions", """

    ==============================

    Hi #{teacher.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a teacher email.
  """
  def deliver_update_email_instructions(teacher, url) do
    deliver(teacher.email, "Update email instructions", """

    ==============================

    Hi #{teacher.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
