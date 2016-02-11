defmodule Trello.SnapshotSavingTest do
  use ProjectStatus.ModelCase
  import Ecto.Query

  alias ProjectStatus.Project
  alias ProjectStatus.TrackerSnapshot
  alias ProjectStatus.TrackerSnapshotStoryStatus
  alias ProjectStatus.TrackerStorySnapshot
  alias ProjectStatus.Trello.SnapshotSaving

  @initial_snapshot_date {{2015, 11, 14}, {15, 32, 11}}
  @snapshot_date {{2015, 11, 15}, {15, 32, 11}}

  @board_list [%{"cards" => [%{"id" => "card1_id", "name" => "[2] Landing page"}],
                 "closed" => false, "id" => "a1",
                 "idBoard" => "54eafa291c316f2112ce7365", "name" => "Master backlog",
                 "pos" => 49151.25, "subscribed" => false},
               %{"cards" => [%{"id" => "5649bb0280afb8d010444464",
                               "name" => "[3] Fully styled landing page with all content"},
                             %{"id" => "5649bade0f4a2216cd17dd14", "name" => "[5] Deploy to production"},
                             %{"id" => "564f4a65aaad9a9538ddb9ec",
                               "name" => "[2] Set up SSH on production server"}], "closed" => false,
                 "id" => "a2", "idBoard" => "54eafa291c316f2112ce7365",
                 "name" => "Blocked", "pos" => 131071, "subscribed" => false}]


  setup context do
    project = %Project{name: "bob"} |> Repo.insert!
    {:ok, pid} = SnapshotSaving.start_link(project.id, @initial_snapshot_date)

    if context[:save_snapshot] do
      pid |> SnapshotSaving.save_snapshot(@snapshot_date, @board_list)
    end
    {:ok, %{project: project, pid: pid}}
  end

  test "initial datetime is set", %{pid: pid} do
    assert @initial_snapshot_date == pid |> SnapshotSaving.last_snapshot_datetime
  end

  @tag :save_snapshot
  test "snapshot record saved", %{project: %{id: project_id}} do
    snapshot = Repo.one!(TrackerSnapshot)
    assert snapshot.project_id == project_id
    assert snapshot.snapshot_datetime |> Ecto.DateTime.to_erl == @snapshot_date
  end

  @tag :save_snapshot
  test "last_snapshot_datetime is updated", %{pid: pid} do
    assert @snapshot_date == pid |> SnapshotSaving.last_snapshot_datetime
  end

  @tag :save_snapshot
  test "trello columns saved as tracker status" do
    tracker_status = (
      from c in TrackerSnapshotStoryStatus,
      join: sn in TrackerSnapshot, on: sn.id == c.tracker_snapshot_id,
      select: c
    ) |> Repo.all

    assert tracker_status |> length == 2

    assert ["a1", "a2"] == tracker_status
    |> Enum.map(&(&1.tracker_status_identifer))
    |> Enum.sort

    assert ["Blocked", "Master backlog"] == tracker_status
    |> Enum.map(&(&1.name))
    |> Enum.sort
  end

  @tag :save_snapshot
  test "cards saved against tracker status (ie columns)" do
    card_counts = TrackerStorySnapshot
    |> group_by([c], c.tracker_snapshot_story_status_id)
    |> select([c], count(c.id))
    |> Repo.all
    |> Enum.sort

    assert [1, 3] == card_counts

    [master_back_log_card]= (
      from s in TrackerStorySnapshot,
      join: c in TrackerSnapshotStoryStatus, on: c.id == s.tracker_snapshot_story_status_id,
      where: c.name == "Master backlog",
      select: s
    ) |> Repo.all


    assert master_back_log_card.tracker_story_identifier == "card1_id"
    assert master_back_log_card.story_text == "Landing page"
    assert master_back_log_card.story_points == 2
  end
end
