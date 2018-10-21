defmodule DocGen.Content.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc "The tags schema for identifying keywords of videos"

  alias DocGen.Content.Video

  schema "tags" do
    field(:name, :string)
    field(:weight, :integer, default: 1)

    many_to_many(:videos, Video,
      join_through: "videos_tags",
      on_replace: :delete,
      on_delete: :delete_all
    )

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :weight])
    |> unique_constraint(:name)
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[\w ]*$/)
    |> validate_number(:weight, greater_than: 0)
  end
end
