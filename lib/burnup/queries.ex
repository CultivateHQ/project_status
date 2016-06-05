defmodule Burnup.Queries do
  import Ecto.Query

  alias ProjectStatus.{Project, Repo, ProjectStoryStatus}

  def raw_totals(project_id) do
    query = from(p in Project,
                 join: s in assoc(p, :tracker_snapshots),
                 join: c in assoc(s, :tracker_snapshot_story_status),
                 join: x in assoc(c, :tracker_story_snapshots),
                 where: p.id == ^project_id,
                 group_by: [s.snapshot_datetime, c.tracker_status_identifer, c.name],
                 select: {s.snapshot_datetime, c.tracker_status_identifer, c.name, sum(x.story_points)},
                 order_by: s.snapshot_datetime)
    query
    |> Repo.all
    |> Enum.map(fn {ecto_datetime, status_id, name, total_points} ->
      {ecto_datetime |> Ecto.DateTime.to_erl, status_id, name, total_points}
    end)
  end

  def story_status_categories(project_id) do
    query = from(s in ProjectStoryStatus, where: s.project_id == ^project_id, select: {s.status_identifier, s.status_category})
    query
    |> Repo.all
    |> Enum.into(%{})
  end
end
