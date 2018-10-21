defmodule DocGen.Content.Type do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc "Types of videos (B-roll and Interview)"

  schema "types" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
