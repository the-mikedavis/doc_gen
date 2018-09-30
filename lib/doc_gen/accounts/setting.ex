defmodule DocGen.Accounts.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field(:title, :string)
    field(:length, :integer)
    field(:copy, :string)

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:name, :length])
    |> validate_required([:name, :length])
    |> validate_length(:name, min: 3, max: 100)
    |> validate_inclusion(:length, 5..8_000)
  end
end
