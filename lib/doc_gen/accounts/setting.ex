defmodule DocGen.Accounts.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field(:length, :integer)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:name, :length])
    |> validate_required([:name, :length])
  end
end
