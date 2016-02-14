defmodule ProjectStatus.Trello.TrelloProjects do
  import Ecto.Query

  alias ProjectStatus.Repo
  alias ProjectStatus.Project

  def projects_and_last_snapshots do
    from(p in Project,
         left_join: s in assoc(p, :tracker_snapshots),
         where: not is_nil(p.trello_project_id),
         group_by: [p.id, p.trello_project_id, p.name],
    select: [p.id, p.trello_project_id, p.name, max(s.snapshot_datetime)])
    |> Repo.all
    |> Enum.map(fn [id, trello_board_id, name, snapshot_datetime] ->
      %{id: id,
        trello_board_id: trello_board_id,
        name: name,
        snapshot_datetime: drop_milliseconds(snapshot_datetime)}
    end)
  end

  defp drop_milliseconds(nil), do: nil
  defp drop_milliseconds({date, {h,m,s,_ms}}), do: {date, {h, m, s}}
end

defmodule ProjectStatus.Trello.ProjectSnapshotManager do
end
