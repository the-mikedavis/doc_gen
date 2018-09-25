defmodule DocGenWeb.Plugs.Auth do
  @moduledoc false
  import Plug.Conn

  alias DocGen.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  @spec login(
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