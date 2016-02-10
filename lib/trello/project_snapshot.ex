defmodule ProjectStatus.Trello.ProjectSnapshot do
  use GenServer

  def start_link(trello_board_id, snapshot_saving, last_snapshot_datetime, opts \\ []) do
    GenServer.start_link(__MODULE__, {trello_board_id, snapshot_saving, last_snapshot_datetime}, opts)
  end

  def init(state = {_project_id, _trello_board_id, _last_snapshot_datetime}) do
    {:ok, state}
  end

  ## API
  def take_snapshot(pid) do
    pid |> GenServer.cast(:take_snapshot)
  end


  ## Callbacks
  def handle_cast(:take_snapshot, {trello_board_id, snapshot_saving, _last_snapshot_datetime}) do
    {:ok, board_lists} = ProjectStatus.Trello.fetch_board_lists(trello_board_id)
    now = :erlang.universaltime
    snapshot_saving |> ProjectStatus.Trello.SnapshotSaving.save_snapshot(now, board_lists)
    {:noreply, {trello_board_id, snapshot_saving, now}}
  end
end
