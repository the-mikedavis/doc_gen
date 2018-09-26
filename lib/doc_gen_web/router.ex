defmodule DocGenWeb.Router do
  use DocGenWeb, :router

  alias DocGenWeb.Plugs

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Plugs.Auth)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", DocGenWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/watch/:id", WatchController, :show)
  end

  scope "/admin", DocGenWeb do
    pipe_through(:browser)

    resources("/user", UserController)
    resources("/session", SessionController, only: [:new, :create, :delete])
    resources("/videos", VideoController)
  end
end
