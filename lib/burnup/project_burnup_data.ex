defmodule Burnup.ProjectBurnupData do
  use GenServer

  import Ecto.Query

  alias ProjectStatus.{Project, Repo, TrackerSnapshot, TrackerSnapshotStoryStatus, TrackerStorySnapshot}

  defstruct project_id: nil

  def start_link(project_id) do
    GenServer.start_link(__MODULE__, project_id, name: __MODULE__)
  end

  def raw_totals(pid) do
    pid |> GenServer.call(:raw_totals)
  end

  ## Callbacks
  def init(project_id) do
    {:ok, %__MODULE__{project_id: project_id}}
  end

  def handle_call(:raw_totals, _from, state = %{project_id: project_id}) do
    query = from(p in Project,
                 join: s in assoc(p, :tracker_snapshots),
                 join: c in assoc(s, :tracker_snapshot_story_status),
                 left_join: x in assoc(c, :tracker_story_snapshots),
                 where: p.id == ^project_id,
                 group_by: [s.snapshot_datetime, c.tracker_status_identifer, c.name],
                 select: {s.snapshot_datetime, c.tracker_status_identifer, c.name, sum(x.story_points)},
                 order_by: s.snapshot_datetime)
    result = query
    |> Repo.all
    |> Enum.map(fn {ecto_datetime, status_id, name, total_points} ->
      {ecto_datetime |> Ecto.DateTime.to_erl, status_id, name, total_points}
    end)
    {:reply, result, state}
  end
end
