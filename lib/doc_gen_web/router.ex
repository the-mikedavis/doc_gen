defmodule DocGenWeb.Router do
  use DocGenWeb, :router

  alias DocGenWeb.Plugs

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Plugs.User)
    plug(Plugs.Title)
  end

  pipeline :authenticate do
    plug(Plugs.Auth)
  end

  scope "/", DocGenWeb do
    pipe_through(:browser)

    get("/", WatchController, :index)
    post("/watch", WatchController, :show)
    post("/watch/:video", WatchController, :choose)
    get("/stream/:id", WatchController, :stream)
    resources("/session", SessionController, only: [:new, :create, :delete])
  end

  scope "/admin", DocGenWeb do
    pipe_through([:browser, :authenticate])

    resources("/user", UserController)
    resources("/videos", VideoController)
    get("/dashboard", DashboardController, :index)
    resources("/settings", SettingsController, only: [:index, :update])
  end
end
