defmodule EventAppWeb.EventController do
  use EventAppWeb, :controller

  alias EventApp.Events
  alias EventApp.Events.Event
  alias EventApp.Comments.Comment
  alias EventApp.Invites
  alias EventApp.Invites.Invite
  alias EventApp.Users

  plug :fetch_event when action in [:show, :edit, :update, :delete]
  plug :require_login when action in [:show, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]
  plug :require_owner_or_invited when action in [:show]

  def fetch_event(conn, _args) do
    event = Events.get_event! conn.params["id"]
    assign conn, :event, event
  end

  def require_login(conn, _args) do
    if logged_in?(conn) do
      conn
    else
      conn
      |> put_flash(:info, "Please log in above or sign up below to view that event")
      |> redirect(to: Routes.user_path(conn, :new, return_to: Routes.event_path(conn, :show, conn.assigns[:event])))
    end
  end

  def require_owner(conn, _args) do
    if owner?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You do not own that event")
      |> redirect(to: Routes.event_path(conn, :show, conn.assigns[:event]))
    end
  end

  def require_owner_or_invited(conn, _args) do
    if owner?(conn) or invited?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You are not invited to that event")
      |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def index(conn, _params) do
    events = if logged_in?(conn), do: Events.events_for(conn.assigns[:current_user]), else: []
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event_params = event_params
    |> Map.put("user_id", conn.assigns[:current_user].id)
    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    event = conn.assigns[:event]
    comment_changeset = Comment.changeset(%Comment{})
    invite = Invites.get_by_event_id_and_email(event.id, conn.assigns[:current_user].email)
    invite_changeset = Invite.changeset(invite || %Invite{})

    invited_emails = Enum.map(event.invites, fn x -> x.email end)
    invited_users_by_email = Users.get_users_by_emails(invited_emails)
    |> Enum.map(fn x -> {x.email, x.name} end)
    |> Map.new

    invites = for response <- Ecto.Enum.values(Invite, :response) ++ [nil], into: %{} do
      {response, Enum.map(Enum.filter(event.invites, fn x -> x.response == response end), fn y -> invited_users_by_email[y.email] || y.email end)}
    end

    render(
            conn, 
            "show.html", 
            event: event,
            owner: owner?(conn),
            invited: invited?(conn),
            invite: invite,
            invites: invites,
            comment_changeset: comment_changeset,
            invite_changeset: invite_changeset
          )
  end

  def edit(conn, _params) do
    event = conn.assigns[:event]
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"event" => event_params}) do
    event = conn.assigns[:event]

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    event = conn.assigns[:event]
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end

  defp owner?(conn) do
    conn.assigns[:current_user].id == conn.assigns[:event].user_id
  end

  defp invited?(conn) do
    conn.assigns[:event].invites
    |> Enum.any? fn x -> x.email == conn.assigns[:current_user].email end
  end
end
