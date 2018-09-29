defmodule DocGenWeb.Plugs.Auth do
  @moduledoc false
  import Plug.Conn
  use DocGenWeb, :controller

  alias DocGen.Accounts

  def init(opts), do: opts

  # only let the conn in if they're a user
  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must sign in to access that page.")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  @spec login(Plug.Conn.t(), String.t(), String.t()) ::
          {:ok, Plug.Conn.t()} | {:error, atom(), Plug.Conn.t()}
  def login(conn, uname, given_pass) do
    case Accounts.authenticate(uname, given_pass) do
      {:ok, user} ->
        {:ok, login(conn, user)}

      {:error, :unauthorized} ->
        {:error, :unauthorized, conn}

      {:error, :not_found} ->
        {:error, :not_found, conn}
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn), do: configure_session(conn, drop: true)
end
