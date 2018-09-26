defmodule DocGenWeb.UserController do
  use DocGenWeb, :controller
  use Private

  alias DocGen.{Accounts, Accounts.User}

  plug(:authenticate)
  plug(:is_user when action in [:edit, :change, :delete])

  def index(conn, _params) do
    user = Accounts.list_user()
    render(conn, "index.html", user: user)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> assign(:current_user, user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.user
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = conn.assigns.user

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  private do
    # check whether or not the user is logged in
    @spec authenticate(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
    defp authenticate(conn, _opts) do
      if conn.assigns[:current_user] do
        conn
      else
        conn
        |> put_flash(:error, "You must sign in to access that page.")
        |> redirect(to: Routes.session_path(conn, :new))
        |> halt()
      end
    end

    # allow passage if and only if this user is the user they're trying to
    # access.
    @spec is_user(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
    defp is_user(conn, opts) do
      id = conn.params["id"]
      user = Accounts.get_user!(id)

      # we can use the dot notation because this is run after the authenticate
      # plug
      if id && conn.assigns.current_user.id == id do
        assign(conn, :user, user)
      else
        conn
        |> put_flash(:error, "You cannot modify a different user.")
        |> redirect(to: Routes.user_path(conn, :index))
        |> halt()
      end
    end
  end
end
