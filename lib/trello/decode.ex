defmodule Trello.Decode do
  def sum_story_points(board_data) do
    board_data |> Enum.reduce([], fn (queue, acc) ->
      [{queue["name"], sum_card_story_points(queue["cards"])} | acc]
    end)
    |> Enum.reverse
  end

  def split_name_into_points_and_name(card_name) do
    case Regex.named_captures(~r/^\s*\[(?<points>\d+)\](?<rest>.*)/, card_name) do
      %{"points" => points, "rest" => rest} -> {String.to_integer(points), String.strip(rest)}
      _ -> {nil, card_name}
    end
  end

  defp sum_card_story_points(cards) do
    sum_card_story_points(cards, 0)
  end

  defp sum_card_story_points([], sum) do
    sum
  end

  defp sum_card_story_points([%{"name" => card_name}| rest], sum) do
    sum_card_story_points(rest, sum + points_for_card_name(card_name))
  end

  defp points_for_card_name(card_name) do
    case split_name_into_points_and_name(card_name) do
      {nil, _} -> 0
      {points, _} -> points
    end
  end
end
