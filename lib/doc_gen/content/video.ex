defmodule DocGen.Content.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  The Video context.
  """

  schema "videos" do
    field(:slug, :string)
    field(:video_file, :any, virtual: true)
    field(:title, :string)

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:title, :slug, :video_file])
    |> validate_required([:title, :video_file])
    |> unique_constraint(:slug)
  end
end
