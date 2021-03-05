defmodule EventApp.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :naive_datetime
    field :description, :string, default: ""
    field :title, :string

    belongs_to :user, EventApp.Users.User

    timestamps()
  end

  @doc false
  # note: allow blank description so it can default to ""
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :date, :description, :user_id])
    |> validate_required([:title, :date, :user_id])
  end

  def date_display(event) do
    date = event.date

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

    "#{date.month}/#{date.day}/#{date.year} at #{hour}:#{minute_buffer}#{date.minute} #{am_pm}"
  end
end
