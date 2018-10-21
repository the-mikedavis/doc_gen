defmodule DocGen.Content.Segment do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc "The segment of the video: beginning, middle, or end"

  alias DocGen.Content.Video

  schema "segments" do
    field(:name, :string)
    has_many(:videos, Video)

    timestamps()
  end

  @doc false
  def changeset(segment, attrs) do
    segment
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
