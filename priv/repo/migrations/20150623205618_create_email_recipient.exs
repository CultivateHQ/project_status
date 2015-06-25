defmodule ProjectStatus.Repo.Migrations.CreateEmailRecipient do
  use Ecto.Migration

  def change do
    create table(:email_recipients) do
      add :project_id, :integer
      add :name, :string
      add :email, :string

      timestamps
    end

  end
end
