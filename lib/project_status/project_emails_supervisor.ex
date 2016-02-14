defmodule ProjectStatus.ProjectEmailsSupervisor do
  use Supervisor
  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(ProjectStatus.ProjectEmails, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def start_project_snapshot(project_id, trello_board_id, last_snapshot_datetime \\ nil) do
    Supervisor.start_child(__MODULE__, [project_id, trello_board_id, last_snapshot_datetime])
  end
end
