defmodule DocGen.Content.Video do
  use Ecto.Schema
  import Ecto.Changeset


  schema "videos" do
    field :slug, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:title, :slug])
    |> validate_required([:title, :slug])
    |> unique_constraint(:slug)
  end
end
