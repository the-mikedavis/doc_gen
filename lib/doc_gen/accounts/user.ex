defmodule DocGen.Accounts.User do
  use Private
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  The User. All users are admins.
  """

  schema "user" do
    field(:hashed_password, :string)
    field(:password, :string, virtual: true)
    field(:username, :string)

    timestamps()
  end

  @doc false
  @spec changeset(%__MODULE__{}, %{}) :: %Ecto.Changeset{}
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:password, min: 6, max: 30)
    |> validate_length(:username, min: 3, max: 15)
    |> validate_format(:username, ~r/^[\w\-\_]*$/)
    |> unique_constraint(:username)
    |> put_password_hash()
  end

  private do
    # whenever there is a change to the password (or addition of that field),
    # also put in a hashed password.
    @spec put_password_hash(%Ecto.Changeset{}) :: %Ecto.Changeset{}
    defp put_password_hash(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
          put_change(
            changeset,
            :password_hash,
            Comeonin.Bcrypt.hashpwsalt(pass)
          )

        _ ->
          changeset
      end
    end
  end
end
