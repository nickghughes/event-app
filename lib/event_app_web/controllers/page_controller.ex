defmodule EventAppWeb.PageController do
  use EventAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
