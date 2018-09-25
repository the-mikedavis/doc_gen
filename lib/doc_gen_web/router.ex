defmodule DocGenWeb.Router do
  use DocGenWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", DocGenWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/admin", DocGenWeb do
    pipe_through(:browser)

    resources("/user", UserController)
  end
end
