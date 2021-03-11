# Credit lecture notes at https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/11-photoblog/notes.md
defmodule EventAppWeb.SessionController do
  use EventAppWeb, :controller

  def create(conn, %{"email" => email}) do
    user = EventApp.Users.get_user_by_email(email)

    if user do
      redirect_to = case conn.params["return_to"] do
        path when path in [nil, ""] ->
          Routes.event_path(conn, :index)
        path ->
          path
      end

      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Welcome back, #{user.name}!")
      |> redirect(to: redirect_to)
    else
      conn
      |> put_flash(:error, "Login failed.")
      |> redirect(to: Routes.event_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end