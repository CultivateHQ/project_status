defmodule ProjectStatus.GuardianSerializer do
  @behaviour Guardian.Serializer

  def for_token(token), do: {:ok, token}
  def from_token(token), do: {:ok, token}
end
