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
end
