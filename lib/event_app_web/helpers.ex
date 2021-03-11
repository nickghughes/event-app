defmodule EventAppWeb.Helpers do
  def logged_in?(conn) do
    conn.assigns[:current_user] != nil
  end
end