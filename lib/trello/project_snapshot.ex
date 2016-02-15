defmodule ProjectStatus.Trello.ProjectSnapshot do
  require Logger
  use GenServer
  alias ProjectStatus.Trello.SnapshotSaving
  import ProjectStatus.Trello.SnapshotTiming

  @snapshot_at {3, 30, 0}

  def start_link(project_id, trello_board_id, last_snapshot_datetime, opts \\ []) do
    GenServer.start_link(__MODULE__, {project_id, trello_board_id, last_snapshot_datetime}, opts)
  end

  def init({project_id, trello_board_id, last_snapshot_datetime}) do
    Logger.info("Starting Trello snapshot monitoring for project #{project_id}")

    {:ok, saving_pid} = SnapshotSaving.start_link(project_id, last_snapshot_datetime)
    set_timer_for_next_poll
    {:ok, {trello_board_id, saving_pid}}
  end

  ## API
  def take_snapshot(pid) do
    pid |> GenServer.cast(:take_snapshot)
  end

  def last_snapshot_datetime(pid) do
    pid |> GenServer.call(:last_snapshot_datetime)
  end


  ## Callbacks
  def handle_cast(:take_snapshot, state = {trello_board_id, saving_pid }) do
    Logger.info("Taking Trello snapshot for project #{saving_pid |> SnapshotSaving.project_id}")

    take_snapshot(trello_board_id, saving_pid)
    {:noreply, state}
  end

  def handle_call(:last_snapshot_datetime, _from, state = {_, saving_pid})  do
    reply = saving_pid |> SnapshotSaving.last_snapshot_datetime
    {:reply, reply, state}
  end

  def handle_info(:snapshot_check, state = {trello_board_id, saving_pid}) do
    Logger.debug "snapshot_check"
    last_snapshot = saving_pid |> SnapshotSaving.last_snapshot_datetime
    if (snapshot_due?(last_snapshot: last_snapshot, now: :erlang.universaltime, snapshot_at: @snapshot_at)) do
      take_snapshot(trello_board_id, saving_pid)
    end
    set_timer_for_next_poll
    {:noreply, state}
  end

  defp take_snapshot(trello_board_id, saving_pid) do
    {:ok, board_lists} = ProjectStatus.Trello.fetch_board_lists(trello_board_id)
    now = :erlang.universaltime
    saving_pid |> SnapshotSaving.save_snapshot(now, board_lists)
  end

  defp set_timer_for_next_poll do
    poll_time = slightly_randomised_next_poll_time
    Logger.debug("#{self |> inspect} polling in #{poll_time / 60 / 1000} minutes")
    Process.send_after(self, :snapshot_check, poll_time)
  end
end
