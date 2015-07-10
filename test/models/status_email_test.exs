defmodule ProjectStatus.StatusEmailTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.StatusEmail

  @valid_attrs %{content: "some content", project_id: 42, sent_date: %{day: 17, month: 4, year: 2010}, status_date: %{day: 17, month: 4, year: 2010}, subject: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StatusEmail.changeset(%StatusEmail{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StatusEmail.changeset(%StatusEmail{}, @invalid_attrs)
    refute changeset.valid?
  end
end
