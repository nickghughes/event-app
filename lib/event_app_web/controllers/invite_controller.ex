defmodule EventAppWeb.InviteController do
  use EventAppWeb, :controller

  alias EventApp.Invites
  alias EventApp.Invites.Invite
  alias EventApp.Events

  plug :require_event_owner when action in [:create]
  plug :require_invitee when action in [:update]

  # Only allow event owners to send invites
  def require_event_owner(conn, _args) do
    event = Events.get_event! conn.params["event_id"]
    if logged_in?(conn) and conn.assigns[:current_user].id == event.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission for that")
      |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  # Only allow invitees to edit their own invitation responses
  def require_invitee(conn, _args) do
    event = Events.get_event! conn.params["event_id"]
    if logged_in?(conn) and conn.assigns[:current_user].email in Enum.map(event.invites, fn x -> x.email end) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission for that")
      |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def index(conn, _params) do
    invites = Invites.list_invites()
    render(conn, "index.html", invites: invites)
  end

  def new(conn, _params) do
    changeset = Invites.change_invite(%Invite{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invite" => invite_params, "event_id" => event_id}) do
    event = Events.get_event!(event_id)
    invite_params = invite_params
    |> Map.put("event_id", event.id)
    case Invites.create_invite(invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Can't leave email blank.")
        |> redirect(to: Routes.event_path(conn, :show, event))
    end
  end

  def show(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    render(conn, "show.html", invite: invite)
  end

  def edit(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    changeset = Invites.change_invite(invite)
    render(conn, "edit.html", invite: invite, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invite" => invite_params, "event_id" => event_id}) do
    event = Events.get_event!(event_id)
    invite = Invites.get_invite!(id)

    case Invites.update_invite(invite, invite_params) do
      {:ok, invite} ->
        conn
        |> put_flash(:info, "Invite updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Something went wrong.")
        |> redirect(to: Routes.event_path(conn, :show, event))
    end
  end

  def delete(conn, %{"id" => id}) do
    invite = Invites.get_invite!(id)
    {:ok, _invite} = Invites.delete_invite(invite)

    conn
    |> put_flash(:info, "Invite deleted successfully.")
    |> redirect(to: Routes.invite_path(conn, :index))
  end
end
