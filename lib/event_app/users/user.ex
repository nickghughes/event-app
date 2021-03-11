defmodule EventApp.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :profile_photo_hash, :string

    has_many :events, EventApp.Events.Event
    has_many :comments, EventApp.Comments.Comment

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :profile_photo_hash])
    |> validate_required([:name, :email])
  end
end
