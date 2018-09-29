defmodule DocGen.Content.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias DocGen.Content.Video

  schema "tags" do
    field(:name, :string)
    field(:weight, :integer, default: 1)
    belongs_to(:video, Video)

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :weight])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[\w ]*$/)
    |> validate_number(:weight, greater_than: 0)
  end
end
