defmodule EventApp.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :response, :string
      add :email, :string, null: false
      add :event_id, references(:events), null: false

      timestamps()
    end
  end
end
