defmodule App.TeachersTest do
  use App.DataCase

  alias App.Teachers

  describe "teachers" do
    alias App.Teachers.Teacher

    import App.TeachersFixtures

    @invalid_attrs %{}

    test "list_teachers/0 returns all teachers" do
      teacher = teacher_fixture()
      assert Teachers.list_teachers() == [teacher]
    end

    test "get_teacher!/1 returns the teacher with given id" do
      teacher = teacher_fixture()
      assert Teachers.get_teacher!(teacher.id) == teacher
    end

    test "create_teacher/1 with valid data creates a teacher" do
      valid_attrs = %{}

      assert {:ok, %Teacher{} = teacher} = Teachers.create_teacher(valid_attrs)
    end

    test "create_teacher/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teachers.create_teacher(@invalid_attrs)
    end

    test "update_teacher/2 with valid data updates the teacher" do
      teacher = teacher_fixture()
      update_attrs = %{}

      assert {:ok, %Teacher{} = teacher} = Teachers.update_teacher(teacher, update_attrs)
    end

    test "update_teacher/2 with invalid data returns error changeset" do
      teacher = teacher_fixture()
      assert {:error, %Ecto.Changeset{}} = Teachers.update_teacher(teacher, @invalid_attrs)
      assert teacher == Teachers.get_teacher!(teacher.id)
    end

    test "delete_teacher/1 deletes the teacher" do
      teacher = teacher_fixture()
      assert {:ok, %Teacher{}} = Teachers.delete_teacher(teacher)
      assert_raise Ecto.NoResultsError, fn -> Teachers.get_teacher!(teacher.id) end
    end

    test "change_teacher/1 returns a teacher changeset" do
      teacher = teacher_fixture()
      assert %Ecto.Changeset{} = Teachers.change_teacher(teacher)
    end
  end

  import App.TeachersFixtures
  alias App.Teachers.{Teacher, TeacherToken}

  describe "get_teacher_by_email/1" do
    test "does not return the teacher if the email does not exist" do
      refute Teachers.get_teacher_by_email("unknown@example.com")
    end

    test "returns the teacher if the email exists" do
      %{id: id} = teacher = teacher_fixture()
      assert %Teacher{id: ^id} = Teachers.get_teacher_by_email(teacher.email)
    end
  end

  describe "get_teacher_by_email_and_password/2" do
    test "does not return the teacher if the email does not exist" do
      refute Teachers.get_teacher_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the teacher if the password is not valid" do
      teacher = teacher_fixture()
      refute Teachers.get_teacher_by_email_and_password(teacher.email, "invalid")
    end

    test "returns the teacher if the email and password are valid" do
      %{id: id} = teacher = teacher_fixture()

      assert %Teacher{id: ^id} =
               Teachers.get_teacher_by_email_and_password(teacher.email, valid_teacher_password())
    end
  end

  describe "get_teacher!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Teachers.get_teacher!(-1)
      end
    end

    test "returns the teacher with the given id" do
      %{id: id} = teacher = teacher_fixture()
      assert %Teacher{id: ^id} = Teachers.get_teacher!(teacher.id)
    end
  end

  describe "register_teacher/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Teachers.register_teacher(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Teachers.register_teacher(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Teachers.register_teacher(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = teacher_fixture()
      {:error, changeset} = Teachers.register_teacher(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Teachers.register_teacher(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers teachers with a hashed password" do
      email = unique_teacher_email()
      {:ok, teacher} = Teachers.register_teacher(valid_teacher_attributes(email: email))
      assert teacher.email == email
      assert is_binary(teacher.hashed_password)
      assert is_nil(teacher.confirmed_at)
      assert is_nil(teacher.password)
    end
  end

  describe "change_teacher_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Teachers.change_teacher_registration(%Teacher{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_teacher_email()
      password = valid_teacher_password()

      changeset =
        Teachers.change_teacher_registration(
          %Teacher{},
          valid_teacher_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_teacher_email/2" do
    test "returns a teacher changeset" do
      assert %Ecto.Changeset{} = changeset = Teachers.change_teacher_email(%Teacher{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_teacher_email/3" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "requires email to change", %{teacher: teacher} do
      {:error, changeset} = Teachers.apply_teacher_email(teacher, valid_teacher_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{teacher: teacher} do
      {:error, changeset} =
        Teachers.apply_teacher_email(teacher, valid_teacher_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{teacher: teacher} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Teachers.apply_teacher_email(teacher, valid_teacher_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{teacher: teacher} do
      %{email: email} = teacher_fixture()
      password = valid_teacher_password()

      {:error, changeset} = Teachers.apply_teacher_email(teacher, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{teacher: teacher} do
      {:error, changeset} =
        Teachers.apply_teacher_email(teacher, "invalid", %{email: unique_teacher_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{teacher: teacher} do
      email = unique_teacher_email()
      {:ok, teacher} = Teachers.apply_teacher_email(teacher, valid_teacher_password(), %{email: email})
      assert teacher.email == email
      assert Teachers.get_teacher!(teacher.id).email != email
    end
  end

  describe "deliver_teacher_update_email_instructions/3" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "sends token through notification", %{teacher: teacher} do
      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_update_email_instructions(teacher, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert teacher_token = Repo.get_by(TeacherToken, token: :crypto.hash(:sha256, token))
      assert teacher_token.teacher_id == teacher.id
      assert teacher_token.sent_to == teacher.email
      assert teacher_token.context == "change:current@example.com"
    end
  end

  describe "update_teacher_email/2" do
    setup do
      teacher = teacher_fixture()
      email = unique_teacher_email()

      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_update_email_instructions(%{teacher | email: email}, teacher.email, url)
        end)

      %{teacher: teacher, token: token, email: email}
    end

    test "updates the email with a valid token", %{teacher: teacher, token: token, email: email} do
      assert Teachers.update_teacher_email(teacher, token) == :ok
      changed_teacher = Repo.get!(Teacher, teacher.id)
      assert changed_teacher.email != teacher.email
      assert changed_teacher.email == email
      assert changed_teacher.confirmed_at
      assert changed_teacher.confirmed_at != teacher.confirmed_at
      refute Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end

    test "does not update email with invalid token", %{teacher: teacher} do
      assert Teachers.update_teacher_email(teacher, "oops") == :error
      assert Repo.get!(Teacher, teacher.id).email == teacher.email
      assert Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end

    test "does not update email if teacher email changed", %{teacher: teacher, token: token} do
      assert Teachers.update_teacher_email(%{teacher | email: "current@example.com"}, token) == :error
      assert Repo.get!(Teacher, teacher.id).email == teacher.email
      assert Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end

    test "does not update email if token expired", %{teacher: teacher, token: token} do
      {1, nil} = Repo.update_all(TeacherToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Teachers.update_teacher_email(teacher, token) == :error
      assert Repo.get!(Teacher, teacher.id).email == teacher.email
      assert Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end
  end

  describe "change_teacher_password/2" do
    test "returns a teacher changeset" do
      assert %Ecto.Changeset{} = changeset = Teachers.change_teacher_password(%Teacher{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Teachers.change_teacher_password(%Teacher{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_teacher_password/3" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "validates password", %{teacher: teacher} do
      {:error, changeset} =
        Teachers.update_teacher_password(teacher, valid_teacher_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{teacher: teacher} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Teachers.update_teacher_password(teacher, valid_teacher_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{teacher: teacher} do
      {:error, changeset} =
        Teachers.update_teacher_password(teacher, "invalid", %{password: valid_teacher_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{teacher: teacher} do
      {:ok, teacher} =
        Teachers.update_teacher_password(teacher, valid_teacher_password(), %{
          password: "new valid password"
        })

      assert is_nil(teacher.password)
      assert Teachers.get_teacher_by_email_and_password(teacher.email, "new valid password")
    end

    test "deletes all tokens for the given teacher", %{teacher: teacher} do
      _ = Teachers.generate_teacher_session_token(teacher)

      {:ok, _} =
        Teachers.update_teacher_password(teacher, valid_teacher_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end
  end

  describe "generate_teacher_session_token/1" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "generates a token", %{teacher: teacher} do
      token = Teachers.generate_teacher_session_token(teacher)
      assert teacher_token = Repo.get_by(TeacherToken, token: token)
      assert teacher_token.context == "session"

      # Creating the same token for another teacher should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%TeacherToken{
          token: teacher_token.token,
          teacher_id: teacher_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_teacher_by_session_token/1" do
    setup do
      teacher = teacher_fixture()
      token = Teachers.generate_teacher_session_token(teacher)
      %{teacher: teacher, token: token}
    end

    test "returns teacher by token", %{teacher: teacher, token: token} do
      assert session_teacher = Teachers.get_teacher_by_session_token(token)
      assert session_teacher.id == teacher.id
    end

    test "does not return teacher for invalid token" do
      refute Teachers.get_teacher_by_session_token("oops")
    end

    test "does not return teacher for expired token", %{token: token} do
      {1, nil} = Repo.update_all(TeacherToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Teachers.get_teacher_by_session_token(token)
    end
  end

  describe "delete_teacher_session_token/1" do
    test "deletes the token" do
      teacher = teacher_fixture()
      token = Teachers.generate_teacher_session_token(teacher)
      assert Teachers.delete_teacher_session_token(token) == :ok
      refute Teachers.get_teacher_by_session_token(token)
    end
  end

  describe "deliver_teacher_confirmation_instructions/2" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "sends token through notification", %{teacher: teacher} do
      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_confirmation_instructions(teacher, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert teacher_token = Repo.get_by(TeacherToken, token: :crypto.hash(:sha256, token))
      assert teacher_token.teacher_id == teacher.id
      assert teacher_token.sent_to == teacher.email
      assert teacher_token.context == "confirm"
    end
  end

  describe "confirm_teacher/1" do
    setup do
      teacher = teacher_fixture()

      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_confirmation_instructions(teacher, url)
        end)

      %{teacher: teacher, token: token}
    end

    test "confirms the email with a valid token", %{teacher: teacher, token: token} do
      assert {:ok, confirmed_teacher} = Teachers.confirm_teacher(token)
      assert confirmed_teacher.confirmed_at
      assert confirmed_teacher.confirmed_at != teacher.confirmed_at
      assert Repo.get!(Teacher, teacher.id).confirmed_at
      refute Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end

    test "does not confirm with invalid token", %{teacher: teacher} do
      assert Teachers.confirm_teacher("oops") == :error
      refute Repo.get!(Teacher, teacher.id).confirmed_at
      assert Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end

    test "does not confirm email if token expired", %{teacher: teacher, token: token} do
      {1, nil} = Repo.update_all(TeacherToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Teachers.confirm_teacher(token) == :error
      refute Repo.get!(Teacher, teacher.id).confirmed_at
      assert Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end
  end

  describe "deliver_teacher_reset_password_instructions/2" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "sends token through notification", %{teacher: teacher} do
      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_reset_password_instructions(teacher, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert teacher_token = Repo.get_by(TeacherToken, token: :crypto.hash(:sha256, token))
      assert teacher_token.teacher_id == teacher.id
      assert teacher_token.sent_to == teacher.email
      assert teacher_token.context == "reset_password"
    end
  end

  describe "get_teacher_by_reset_password_token/1" do
    setup do
      teacher = teacher_fixture()

      token =
        extract_teacher_token(fn url ->
          Teachers.deliver_teacher_reset_password_instructions(teacher, url)
        end)

      %{teacher: teacher, token: token}
    end

    test "returns the teacher with valid token", %{teacher: %{id: id}, token: token} do
      assert %Teacher{id: ^id} = Teachers.get_teacher_by_reset_password_token(token)
      assert Repo.get_by(TeacherToken, teacher_id: id)
    end

    test "does not return the teacher with invalid token", %{teacher: teacher} do
      refute Teachers.get_teacher_by_reset_password_token("oops")
      assert Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end

    test "does not return the teacher if token expired", %{teacher: teacher, token: token} do
      {1, nil} = Repo.update_all(TeacherToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Teachers.get_teacher_by_reset_password_token(token)
      assert Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end
  end

  describe "reset_teacher_password/2" do
    setup do
      %{teacher: teacher_fixture()}
    end

    test "validates password", %{teacher: teacher} do
      {:error, changeset} =
        Teachers.reset_teacher_password(teacher, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{teacher: teacher} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Teachers.reset_teacher_password(teacher, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{teacher: teacher} do
      {:ok, updated_teacher} = Teachers.reset_teacher_password(teacher, %{password: "new valid password"})
      assert is_nil(updated_teacher.password)
      assert Teachers.get_teacher_by_email_and_password(teacher.email, "new valid password")
    end

    test "deletes all tokens for the given teacher", %{teacher: teacher} do
      _ = Teachers.generate_teacher_session_token(teacher)
      {:ok, _} = Teachers.reset_teacher_password(teacher, %{password: "new valid password"})
      refute Repo.get_by(TeacherToken, teacher_id: teacher.id)
    end
  end

  describe "inspect/2 for the Teacher module" do
    test "does not include password" do
      refute inspect(%Teacher{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
