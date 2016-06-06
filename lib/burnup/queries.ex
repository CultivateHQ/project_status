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

  def categorise_totals(totals, categories) do
    %{
      total: total(totals, categories),
      delivered: delivered(totals, categories),
      accepted: accepted(totals, categories)
    }
  end

  defp accepted(totals, categories), do: totals_for(totals, categories, ["accepted"])

  defp delivered(totals, categories), do: totals_for(totals, categories, ["done", "accepted"])

  defp total(totals, categories), do: totals_for(totals, categories, ["done", "accepted", "todo"])

  defp totals_for(totals, categories, matching_categories) do
    totals
    |> Enum.filter(fn {_date, status_identifier, _name, _total} ->
      matching_categories |> Enum.member?(categories[status_identifier]) end)
    |> Enum.group_by(fn {date, _status_identifier, _name, _total} -> date end)
    |> Enum.map(fn {date, date_totals} -> {date, sum_totals(date_totals)} end)
  end

  defp sum_totals(totals) do
    totals
    |> Enum.reduce(0, fn {_date, _status_identifier, _name, total}, acc -> (total || 0) + acc end)
  end
end
