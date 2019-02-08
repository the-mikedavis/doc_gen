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
    plug(:put_user_token)
  end

  pipeline :authenticate do
    plug(Plugs.Auth)
  end

  scope "/", DocGenWeb do
    pipe_through(:browser)

    get("/", WatchController, :index)
    get("/about", AboutController, :index)
    get("/thumb/:id/jpeg", WatchController, :thumb)
    get("/thumb/:id/gif", WatchController, :anithumb)
    post("/watch", WatchController, :show)
    post("/watch/:video", WatchController, :choose)
    get("/stream/:id", WatchController, :stream)
    resources("/session", SessionController, only: [:new, :create, :delete])
  end

  scope "/admin", DocGenWeb do
    pipe_through([:browser, :authenticate])

    resources("/user", UserController)
    resources("/videos", VideoController)
    resources("/tags", TagController)
    resources("/interviewees", IntervieweeController)
    resources("/settings", SettingsController, only: [:index, :update])
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, socket_token_key(), current_user.id)

      assign(conn, :user_token, token)
    else
      conn
    end
  end

  defp socket_token_key, do: Application.get_env(:doc_gen, :socket_token_key)
end
