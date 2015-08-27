defmodule ProjectStatus.Credentials do

import Application, only: [get_env: 2]

  defp username, do: get_env(:basic_auth, :username)
  defp password, do: get_env(:basic_auth, :password)
  def encoded, do: "Basic " <> Base.encode64("#{username}:#{password}")
end
