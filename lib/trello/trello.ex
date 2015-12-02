defmodule Trello do
  import Trello.Fetch, only: [fetch: 1]
  import Trello.Decode, only: [sum_story_points: 1]

  def extract_project_id(url) do
    case Regex.named_captures(~r/https:\/\/trello.com\/\w\/(?<trello>.+)\//, url) do
      %{"trello" => project_id} -> {:ok, project_id}
      nil -> {:error, "not a Trello url"}
    end
  end

  def sum_points_for_board(board_id) do
    case fetch({:board_lists, board_id}) do
      {:board_lists, board_data} -> {:ok, sum_story_points(board_data)}
      err -> err
    end
  end
end
