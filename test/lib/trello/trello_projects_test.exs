defmodule Trello.TrelloProjectsTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.Project
  alias ProjectStatus.TrackerSnapshot
  alias ProjectStatus.Trello.TrelloProjects


  setup do
    %Project{name: "no trello"} |> Repo.insert!
    project_with_snapshots = %Project{name: "a with snapshot", trello_project_id: "1234"} |> Repo.insert!
    project_without_snapshots = %Project{name: "b without snapshot", trello_project_id: "4567"} |> Repo.insert!

    [{{2016, 2, 15}, {11, 31, 59}}, {{2016, 2, 15}, {11, 32, 0}}, {{2016, 2, 14}, {11, 32, 1}}] |> Enum.each(fn date_time ->
      %TrackerSnapshot{project_id: project_with_snapshots.id, snapshot_datetime: Ecto.DateTime.from_erl(date_time) }
      |> Repo.insert
    end)
    {:ok, %{project_with_snapshots: project_with_snapshots, project_without_snapshots: project_without_snapshots}}
  end

  test "projects_with_last_snapshots gives only projects with project_ids" do
    project_names = (for snapshot <- TrelloProjects.projects_and_last_snapshots, do: snapshot.name) |> Enum.sort
    assert project_names == ["a with snapshot", "b without snapshot"]
  end

  test "only the last snapshot date times are included when available" do
    times = (for snapshot <- TrelloProjects.projects_and_last_snapshots, do: snapshot.snapshot_datetime) |> Enum.sort

    assert times == [nil, {{2016, 2, 15}, {11, 32, 0}}]
  end
end
