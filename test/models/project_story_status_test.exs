defmodule ProjectStatus.ProjectStoryStatusTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.ProjectStoryStatus

  @valid_attrs %{status_category: "some content", status_identifier: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ProjectStoryStatus.changeset(%ProjectStoryStatus{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ProjectStoryStatus.changeset(%ProjectStoryStatus{}, @invalid_attrs)
    refute changeset.valid?
  end
end
