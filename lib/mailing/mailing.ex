defmodule ProjectStatus.Mailing do
  use Mailgun.Client, domain: Application.get_env(:project_status, :mailgun_domain),
    key: Application.get_env(:project_status, :mailgun_key)

  @from "status@cultivatehq.com"


  def send(recipients, subject, content) do
    send_email to: recipients, from: @from, subject: subject, text: content, html: Earmark.to_html(content)
  end
end
