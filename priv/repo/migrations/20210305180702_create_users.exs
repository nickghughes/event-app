defmodule EventApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :profile_photo_hash, :string

      timestamps()
    end

  end
end
