defmodule ProjectStatus.Trello.SnapshotSaving do
  use GenServer

  import Trello.Decode, only: [split_name_into_points_and_name: 1]

  alias ProjectStatus.Repo
  alias ProjectStatus.TrackerSnapshot
  alias ProjectStatus.TrackerSnapshotStoryStatus
  alias ProjectStatus.TrackerStorySnapshot

  def start_link(project_id, opts \\ []) do
    GenServer.start_link(__MODULE__, project_id, opts)
  end

  ## Api
  def save_snapshot(pid, datetime, board_data) do
    pid |> GenServer.call({:save_snapshot, datetime, board_data})
  end

  def init(project_id) do
    {:ok, project_id}
  end

  ## Callbacks

  def handle_call({:save_snapshot, datetime, board_data}, _from, project_id) do
    Repo.transaction(fn ->
      %{id: snapshot_id} = save_tracker_snapshot(datetime, project_id)

      for column <- board_data, do: save_column(column, snapshot_id)

    end)
    {:reply, :ok, project_id}
  end

  defp save_tracker_snapshot(datetime, project_id) do
    %TrackerSnapshot{project_id: project_id,
                     snapshot_datetime: datetime |> Ecto.DateTime.from_erl}
    |> Repo.insert!
  end

  defp save_column(%{"id" => column_id, "name" => name, "cards" => cards}, snapshot_id) do
    %{id: status_id} = %TrackerSnapshotStoryStatus{tracker_snapshot_id: snapshot_id,
                                                   tracker_status_identifer: column_id,
                                                   name: name}
    |> Repo.insert!

    save_cards(cards, status_id)
  end

  defp save_cards(cards, status_id) do
    for card <- cards, do: save_card(card, status_id)
  end

  defp save_card(card, status_id) do
    {points, name} = split_name_into_points_and_name(card["name"])
    %TrackerStorySnapshot{tracker_snapshot_story_status_id: status_id,
                          tracker_story_identifier: card["id"],
                          story_text: name,
                          story_points: points}
    |> Repo.insert!
  end
end
