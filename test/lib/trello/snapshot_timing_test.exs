defmodule ProjectStatus.Trello.SnapshotTimingTest do
  use ExUnit.Case
  import ProjectStatus.Trello.SnapshotTiming

  test "snapshot_due? when last_snapshot was today" do
    refute snapshot_due?(last_snapshot: {{2015,11,12}, {4,0,0}}, now: {{2015, 11, 12}, {4, 0, 0}}, snapshot_at: {4,0,0})
    refute snapshot_due?(last_snapshot: {{2015,11,12}, {4,0,0}}, now: {{2015, 11, 12}, {4, 0, 1}}, snapshot_at: {4,0,0})
    refute snapshot_due?(last_snapshot: {{2015,11,13}, {3,59,58}}, now: {{2015, 11, 13}, {3, 59, 59}}, snapshot_at: {4,0,0})
    assert snapshot_due?(last_snapshot: {{2015,11,13}, {3,59,58}}, now: {{2015, 11, 13}, {4, 0, 0}}, snapshot_at: {4,0,0})
  end

  test "snapshot_due? when last_snapshot was yesterday" do
    refute snapshot_due?(last_snapshot: {{2015,11,12}, {4,0,0}}, now: {{2015, 11, 13}, {3, 59, 59}}, snapshot_at: {4,0,0})
    assert snapshot_due?(last_snapshot: {{2015,11,12}, {4,0,0}}, now: {{2015, 11, 13}, {4, 0, 0}}, snapshot_at: {4,0,0})
    assert snapshot_due?(last_snapshot: {{2015,11,12}, {4,0,0}}, now: {{2015, 11, 13}, {4, 0, 1}}, snapshot_at: {4,0,0})
  end

  test "snapshot_due? was the day before yesterday" do
    assert snapshot_due?(last_snapshot: {{2015,11,12}, {0, 0, 0}}, now: {{2015, 11, 14}, {0, 0,0}}, snapshot_at: {4, 0, 0})
    assert snapshot_due?(last_snapshot: {{2015,11,12}, {23, 59, 59}}, now: {{2015, 11, 14}, {0, 0,0}}, snapshot_at: {4, 0, 0})
    assert snapshot_due?(last_snapshot: {{2015,11,12}, {23, 59, 59}}, now: {{2015, 11, 14}, {23, 59, 59}}, snapshot_at: {4, 0, 0})
  end

  test "snapshot_due? with nil last_snapshot" do
    assert snapshot_due?(last_snapshot: nil, now: {{2015, 11, 14}, {0, 0,0}}, snapshot_at: {4, 0, 0})
  end

  test "slightly_randomised_next_poll_time" do

    polls = (1..1000) |> Enum.map(fn _ ->
      poll_time = slightly_randomised_next_poll_time
      assert poll_time > :timer.minutes(3)
      assert poll_time <= :timer.minutes(20)
      poll_time
    end)
    |> Enum.uniq

    assert length(polls) > 1
  end
end
