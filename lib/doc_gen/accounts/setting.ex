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
    |> cast(attrs, [:title, :length, :copy])
    |> validate_required([:title, :length])
    |> validate_length(:title, min: 3, max: 100)
    |> validate_inclusion(:length, 5..8_000)
  end
end
