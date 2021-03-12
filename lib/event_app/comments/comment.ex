defmodule EventApp.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string

    belongs_to :user, EventApp.Users.User
    belongs_to :event, EventApp.Events.Event

    timestamps()
  end

  @doc false
  def changeset(comment, attrs \\ %{}) do
    comment
    |> cast(attrs, [:body, :user_id, :event_id])
    |> validate_required([:body, :user_id, :event_id])
  end

  # To show comment timestamp on card
  def date_display(comment) do
    date = comment.inserted_at

    am_pm = if date.hour >= 12 do
      "pm"
    else
      "am"
    end

    hour = cond do
      date.hour > 12 -> date.hour - 12
      date.hour == 0 -> 12
      true -> date.hour
    end

    minute_buffer = if date.minute < 10 do
      "0"
    else
      ""
    end

    "#{date.month}/#{date.day}/#{date.year} #{hour}:#{minute_buffer}#{date.minute} #{am_pm}"
  end
end
