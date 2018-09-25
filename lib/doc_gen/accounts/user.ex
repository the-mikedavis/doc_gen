defmodule DocGen.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "user" do
    field :hashed_password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :hashed_password])
    |> validate_required([:username, :hashed_password])
    |> unique_constraint(:username)
  end
end
