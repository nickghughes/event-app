defmodule EventAppWeb.UserController do
  use EventAppWeb, :controller

  alias EventApp.Users
  alias EventApp.Users.User
  alias EventApp.ProfilePhotos

  plug :fetch_user when action in [:show, :edit, :update, :profile_photo]
  plug :require_logged_in_as when action in [:show, :edit, :update]

  # Assign the current user to the connection (the user being accessed, not the logged in user)
  def fetch_user(conn, _args) do
    user = Users.get_user! conn.params["id"]
    assign conn, :user, user
  end

  # Only allow users to see/edit their own information
  def require_logged_in_as(conn, _args) do
    if logged_in?(conn) and conn.assigns[:current_user].id == conn.assigns[:user].id do
      conn
    else
      conn
      |> put_flash(:error, "You do not have permission to view that page")
      |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    upload = user_params["profile_photo"]

    user_params = if upload do
      {:ok, hash} = ProfilePhotos.save_profile_photo(upload.filename, upload.path)
      Map.put(user_params, "profile_photo_hash", hash)
    else
      user_params
    end

    redirect_to = case conn.params["return_to"] do
      path when path in [nil, ""] ->
        Routes.event_path(conn, :index)
      path ->
        path
    end

    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:success, "Registered successfully. Welcome, " <> user.name <> "!")
        |> redirect(to: redirect_to)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, _params) do
    user = conn.assigns[:user]
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    user = conn.assigns[:user]
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns[:user]
    upload = user_params["profile_photo"]

    user_params = if upload do
      {:ok, hash} = ProfilePhotos.save_profile_photo(upload.filename, upload.path)
      Map.put(user_params, "profile_photo_hash", hash)
    else
      user_params
    end

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def profile_photo(conn, _params) do
    user = conn.assigns[:user]
    {:ok, _name, data} = ProfilePhotos.load_profile_photo(user.profile_photo_hash)
    conn
    |> put_resp_content_type("image/jpeg")
    |> send_resp(200, data)
  end
end
