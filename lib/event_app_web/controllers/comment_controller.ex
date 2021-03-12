defmodule EventAppWeb.CommentController do
  use EventAppWeb, :controller

  alias EventApp.Comments
  alias EventApp.Comments.Comment
  alias EventApp.Events
  alias EventApp.Events.Event

  plug :fetch_comment when action in [:delete]
  plug :require_event_owner_or_invitee when action in [:create]
  plug :require_comment_owner when action in [:delete]
  
  def fetch_comment(conn, _args) do
    comment = Comments.get_comment! conn.params["id"]
    assign conn, :comment, comment
  end

  def require_event_owner_or_invitee(conn, _args) do
    event = Events.get_event! conn.params["event_id"]
    if logged_in?(conn) and (conn.assigns[:current_user].id == event.user_id or conn.assigns[:current_user].email in Enum.map(event.invites, fn x -> x.email end)) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission for that")
      |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def require_comment_owner(conn, _args) do
    if owner?(conn) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission for that")
      |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def index(conn, _params) do
    comments = Comments.list_comments()
    render(conn, "index.html", comments: comments)
  end

  def new(conn, _params) do
    changeset = Comments.change_comment(%Comment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"comment" => comment_params, "event_id" => event_id}) do
    event = Events.get_event!(event_id)
    comment_params = comment_params
    |> Map.put("user_id", conn.assigns[:current_user].id)
    |> Map.put("event_id", event.id)
    case Comments.create_comment(comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Can't leave comment blank.")
        |> redirect(to: Routes.event_path(conn, :show, event))
    end
  end

  def show(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    render(conn, "show.html", comment: comment)
  end

  def edit(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    changeset = Comments.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Comments.get_comment!(id)

    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: Routes.comment_path(conn, :show, comment))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    comment = conn.assigns[:comment]
    event = Events.get_event!(comment.event_id)
    {:ok, _comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :show, event))
  end

  defp owner?(conn) do
    logged_in?(conn) and conn.assigns[:comment].user_id == conn.assigns[:current_user].id
  end
end
