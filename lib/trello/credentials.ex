defmodule Trello.Credentials do
  def credentials do
    {Application.get_env(:project_status, :trello_key), Application.get_env(:project_status, :trello_token)}
  end
end
