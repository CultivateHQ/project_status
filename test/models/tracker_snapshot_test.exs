defmodule ProjectStatus.TrackerSnapshotTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.TrackerSnapshot

  @valid_attrs %{snapshot_datetime: "2010-04-17 14:00:00", project_id: 123}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TrackerSnapshot.changeset(%TrackerSnapshot{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TrackerSnapshot.changeset(%TrackerSnapshot{}, @invalid_attrs)
    refute changeset.valid?
  end
end
