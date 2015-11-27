defmodule Trello do
  def extract_project_id(url) do
    case Regex.named_captures(~r/https:\/\/trello.com\/\w\/(?<trello>.+)\//, url) do
      %{"trello" => project_id} -> {:ok, project_id}
      nil -> {:error, "not a Trello url"}
    end
  end

  def sum_points_for_board(board_id) do
    {:board_lists, board_data} = Trello.Fetch.fetch({:board_lists, board_id})
    points = Trello.Decode.sum_story_points(board_data)
    {:ok, points}
  end
end
