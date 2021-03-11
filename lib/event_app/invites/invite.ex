defmodule EventApp.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :response, Ecto.Enum, values: [:yes, :no, :maybe]
    field :email, :string

    belongs_to :event, EventApp.Events.Event

    timestamps()
  end

  @doc false
  def changeset(invite, attrs \\ %{}) do
    invite
    |> cast(attrs, [:response, :email, :event_id])
    |> validate_required([:email, :event_id])
  end
end
