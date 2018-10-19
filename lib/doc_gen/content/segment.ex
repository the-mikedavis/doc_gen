defmodule DocGen.Content.Segment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "segments" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(segment, attrs) do
    segment
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
