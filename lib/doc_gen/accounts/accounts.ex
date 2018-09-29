defmodule DocGen.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias DocGen.{Accounts.User, Accounts.Setting, Repo}

  @doc """
  Returns the list of user.

  ## Examples

      iex> list_user()
      [%User{}, ...]

  """
  def list_user do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc "Log in a user by username and password."
  @spec authenticate(String.t(), String.t()) ::
          {:ok, %User{}} | {:error, atom()}
  def authenticate(username, given_password) do
    user = Repo.get_by(User, username: username)

    cond do
      user && Comeonin.Bcrypt.checkpw(given_password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Comeonin.Bcrypt.dummy_checkpw()

        {:error, :not_found}
    end
  end

  ## Settings things

  @doc "Get the current settings struct."
  @spec get_settings() :: %Setting{}
  def get_settings do
    Repo.one(Setting)
  end

  @doc "Get the current settings struct."
  @spec get_setting!(integer) :: %Setting{}
  def get_setting!(id) do
    Repo.get!(Setting, id)
  end

  @doc "Update the settings"
  @spec update_setting(%Setting{}, %{}) :: {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def update_setting(setting, attrs) do
    setting
    |> Setting.changeset(attrs)
    |> Repo.update()
  end

  @doc "Do the hokey pokey and turn a setting struct into a changeset."
  @spec change_settings(%Setting{}) :: Ecto.Changeset.t()
  def change_settings(%Setting{} = setting) do
    Setting.changeset(setting, %{})
  end
end
