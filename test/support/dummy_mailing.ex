defmodule DummyMailer do
  def start_link do
    if Process.whereis(:mailer_supervisor) do
      Process.unregister(:mailer_supervisor)
    end
    Agent.start_link(
      fn -> %{emailing_result: {:ok, []},
             emails_sent: []}
      end,
    name: :dummy_email_state)

    DummyMailerSupervisor.start_link
  end

  def set_emailing_result(result) do
    Agent.update(:dummy_email_state, fn state -> state |> Map.put(:emailing_result, result) end)
  end

  def record_email(params) do
    Agent.update(:dummy_email_state, fn state ->
      state |> Map.update!(:emails_sent, fn emails_sent -> [params | emails_sent] end)
    end)
  end

  def emails_sent do
    Agent.get(:dummy_email_state, fn state -> state.emails_sent end)
  end
end

defmodule DummyMailerSupervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :mailer_supervisor)
  end

  def init(_) do
    children = [
      worker(DummyMailerWorker, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule DummyMailerWorker do
  use GenServer

  def start_link(client_pid, email) do
    GenServer.start_link(__MODULE__, {client_pid, email})
  end

  def init({client_pid, email} = args) do
    DummyMailer.record_email(email)
    send(client_pid, Agent.get(:dummy_email_state, fn %{emailing_result: res} -> res end))
    {:ok, args}
  end

  def handle_info(:shutdown, args) do
    {:stop, :shutdown, args}
  end
end
