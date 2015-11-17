defmodule ProjectStatus.Repo.Migrations.AddTrelloToProject do
  use Ecto.Migration

  def change do
    alter(table(:projects)) do
      add :trello_project_id, :string
    end
  end
end
