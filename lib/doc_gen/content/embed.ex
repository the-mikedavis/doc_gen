defmodule DocGen.Content.Embed do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  Embeds are a link to youtube where other videos are stored. They're just gonna
  get embedded in iframes.
  """

  schema "embeds" do
    field(:name, :string)
    field(:link, :string)

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:link, :name])
    |> validate_format(:link, ~r{^http[s]?://})
  end
end
