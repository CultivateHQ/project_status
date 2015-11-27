defmodule TrelloTest do
  use ExUnit.Case

  import Trello


  test "extracting trello id from url" do
    assert {:ok, "abcdefghi"} == "https://trello.com/b/abcdefghi/aproject" |> extract_project_id
  end

  test "invalid trello url" do
    assert {:error, "not a Trello url"} == "https://www.google.co.uk" |> extract_project_id
  end
end
