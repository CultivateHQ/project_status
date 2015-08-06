defmodule Mailing do
  use Mailgun.Client, domain: Application.get_env(:project_status, :mailgun_domain),
    Key: Application.get_env(:project_status, :mailgun_key)

  @from "status@cultivatehq.com"


  def send_status_email(recipients, subject, content) do
    send_email to: recipients, from: @from, subject: subject, text: content
  end
end
