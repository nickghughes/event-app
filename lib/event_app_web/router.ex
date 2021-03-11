defmodule EventAppWeb.Router do
  use EventAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EventAppWeb.Plugs.FetchSession
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EventAppWeb do
    pipe_through :browser

    get "/", EventController, :index
    resources "/events", EventController do
      resources "/comments", CommentController, only: [:create, :delete]
      resources "/invites", InviteController, only: [:create, :update]
    end

    get "/register", UserController, :new
    resources "/users", UserController, only: [:new, :create, :show, :edit, :update]

    resources "/sessions", SessionController, 
      only: [:create, :delete], singleton: true

    get "/users/profile_photo/:id", UserController, :profile_photo
  end

  # Other scopes may use custom stacks.
  # scope "/api", EventAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: EventAppWeb.Telemetry
    end
  end
end
