defmodule ProjectStatus.Repo.Migrations.AddFooterToProject do
  use Ecto.Migration

  def change do
    alter(table(:projects)) do
      add :email_footer, :text
    end
  end
end
