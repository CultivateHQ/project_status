defmodule ProjectStatus.Trello do
  def extract_project_id(url) do
    case Regex.named_captures(~r/https:\/\/trello.com\/\w\/(?<trello>.+)\//, url) do
      %{"trello" => project_id} -> {:ok, project_id}
      nil -> {:error, "not a Trello url"}
    end
  end
end
