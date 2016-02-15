defmodule ProjectStatus.Trello.SnapshotSavingSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(ProjectStatus.Trello.ProjectSnapshot, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
