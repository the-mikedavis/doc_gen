defmodule DocGenWeb.SessionController do
  use DocGenWeb, :controller

  alias DocGenWeb.Plugs.Auth

  def new(conn, _), do: render(conn, "new.html")

  def create(conn, %{"session" => %{"username" => u, "password" => pass}}) do
    case Auth.login(conn, u, pass) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.video_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Auth.logout()
    |> redirect(to: Routes.watch_path(conn, :index))
  end
end
