defmodule ProjectStatus.Trello.SnapshotTiming do
  import :calendar, only: [time_to_seconds: 1, date_to_gregorian_days: 1]

  def snapshot_due?(last_snapshot: nil, now: _, snapshot_at: _) do
    true
  end

  def snapshot_due?(last_snapshot: {now_date, last_snapshot_time},
                    now: {now_date, now_time},
                    snapshot_at: snapshot_at) do
    time_to_seconds(now_time) >= time_to_seconds(snapshot_at) &&
      time_to_seconds(last_snapshot_time) < time_to_seconds(snapshot_at)
  end

  def snapshot_due?(last_snapshot: {last_snapshot_date, _last_snapshot_time},
                    now: {now_date, now_time},
                    snapshot_at: snapshot_at) do
    :calendar.date_to_gregorian_days(now_date) - :calendar.date_to_gregorian_days(last_snapshot_date) > 1 ||
      :calendar.time_to_seconds(now_time) >= :calendar.time_to_seconds(snapshot_at)
  end

  def slightly_randomised_next_poll_time do
    minimum_time = :timer.minutes(3)
    random_element = :rand.uniform(:timer.minutes(17))
    minimum_time + random_element
  end
end
