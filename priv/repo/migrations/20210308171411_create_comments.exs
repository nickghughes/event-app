defmodule EventApp.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :string
      add :user_id, references(:users), null: false
      add :event_id, references(:events), null: false

      timestamps()
    end

  end
end
