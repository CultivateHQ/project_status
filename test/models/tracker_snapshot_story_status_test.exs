defmodule ProjectStatus.TrackerSnapshotStoryStatusTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.TrackerSnapshotStoryStatus

  @valid_attrs %{name: "some content", tracker_snapshot_id: 42, tracker_status_identifer: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TrackerSnapshotStoryStatus.changeset(%TrackerSnapshotStoryStatus{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TrackerSnapshotStoryStatus.changeset(%TrackerSnapshotStoryStatus{}, @invalid_attrs)
    refute changeset.valid?
  end
end
