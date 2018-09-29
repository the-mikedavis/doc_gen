defmodule DocGenWeb.UserControllerTest do
  use DocGenWeb.ConnCase
  import Plug.Test

  alias DocGen.{Accounts, Accounts.User}
  alias DocGenWeb.Plugs.Auth

  @create_attrs %{
    password: "some password",
    username: "someusername"
  }
  @other_attrs %{
    username: "someotheruser",
    password: "somepassword"
  }
  @update_attrs %{
    password: "some updated password",
    username: "someusername"
  }
  @invalid_attrs %{hashed_password: "oe", username: "eoo$o"}

  def fixture(:user, attrs \\ @create_attrs) do
    {:ok, user} = Accounts.create_user(attrs)
    user
  end

  describe "rejection of unauthenticated users" do
    test "un-logged in users are rejected", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "regular access operations," do
    setup [:create_user, :authenticate]

    test "index lists all user", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))

      assert html_response(conn, 200) =~ "Listing User"
    end

    test "new user renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))

      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "operations with created users when you are NOT that user" do
    setup [:create_user, :authenticate]

    # TODO: get flash and check it for the message

    test "update user blocks you when you edit someone else", %{conn: conn, user: user} do
      other = fixture(:user, @other_attrs)
      conn = get(conn, Routes.user_path(conn, :edit, other))

      assert redirected_to(conn) == Routes.user_path(conn, :index)
    end

    test "update user blocks you when you update someone else", %{conn: conn, user: user} do
      other = fixture(:user, @other_attrs)
      conn =
        put(conn, Routes.user_path(conn, :update, other), user: @update_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :index)
    end

    test "delete user blocks you when you delete someone else", %{conn: conn, user: user} do
      other = fixture(:user, @other_attrs)
      conn = delete(conn, Routes.user_path(conn, :update, other))

      assert redirected_to(conn) == Routes.user_path(conn, :index)
    end
  end

  describe "operations with created users when you are that user" do
    setup [:create_user, :authenticate]

    test "edit user renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "update user redirects when data is valid", %{conn: conn, user: user} do
      conn =
        put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "Username: someusername"
    end

    test "update user renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit User"
    end

    test "delete user deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp authenticate(%{conn: conn} = opts) do
    %{username: username, password: password} = @create_attrs
    {:ok, conn} =
      conn
      |> init_test_session(%{})
      |> fetch_session()
      |> Auth.login(username, password)

    {:ok, Map.put(opts, :conn, conn)}
  end
end
