defmodule ProjectStatus.Mailing.Mailer do
  use GenServer

  use Mailgun.Client, domain: Application.get_env(:project_status, :mailgun_domain),
  key: Application.get_env(:project_status, :mailgun_key)

  @from "status@cultivatehq.com"
  @timeout 10_000


  def send(recipients, subject, content) do
    {:ok, pid} = Supervisor.start_child(:mailer_supervisor, [self, {recipients, subject, content}])
    monitor_ref = Process.monitor(pid)
    receive do
      {:ok, result} ->
        Process.demonitor(monitor_ref)
        send(pid, :shutdown)
        {:ok, result}
      {:DOWN, _ref, :process, ^pid, _info} -> :error
    after @timeout ->
      Process.demonitor(monitor_ref)
      Process.exit(pid, :kill)
      :timeout
    end
  end

  def start_link(client_pid, {_recipient, _subject, _content} = email) do
    GenServer.start_link(__MODULE__, {client_pid, email})
  end

  def init(args) do
    send(self, :send_email)
    {:ok, args}
  end

  def handle_info(:send_email, {client_pid, {recipients, subject, content}} = args) do
    send_email to: recipients, from: @from, subject: subject, text: content, html: Earmark.to_html(content)
    send(client_pid, {:ok, []})
    {:noreply, args}
  end

  def handle_info(:shutdown, email) do
    {:stop, :shutdown, email}
  end
end
