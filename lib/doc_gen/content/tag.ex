defmodule DocGen.Content.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias DocGen.Content.Video

  schema "tags" do
    field(:name, :string)
    belongs_to(:videos, Video)

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[\w ]*$/)
  end
end
