defmodule ProjectStatus.TrackerStorySnapshotTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.TrackerStorySnapshot

  @valid_attrs %{story_points: 42, story_text: "some content", tracker_snapshot_story_status_id: 42, tracker_story_identifier: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TrackerStorySnapshot.changeset(%TrackerStorySnapshot{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TrackerStorySnapshot.changeset(%TrackerStorySnapshot{}, @invalid_attrs)
    refute changeset.valid?
  end
end
