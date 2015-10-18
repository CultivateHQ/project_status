defmodule ProjectStatus.Mailer.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :mailer_supervisor)
  end

  def init(_) do
    children = [
      worker(ProjectStatus.Mailing.Mailer, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
