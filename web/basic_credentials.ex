defmodule ProjectStatus.Credentials do
  def username, do: "user"
  def password, do: "pwd"
  def encoded, do: "Basic " <> Base.encode64("#{username}:#{password}")
end 
