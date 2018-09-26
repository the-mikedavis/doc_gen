defmodule DocGen.Content.Video do
  use Ecto.Schema
  use Private
  import Ecto.Changeset

  @moduledoc """
  The Video context.
  """

  schema "videos" do
    field(:title, :string)
    field(:video_file, :any, virtual: true)
    field(:filename, :string)
    field(:path, :string)

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:title, :path, :video_file, :filename])
    |> validate_required([:title, :video_file])
    |> unique_constraint(:filename)
    |> put_video_file()
  end

  private do
    defp put_video_file(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{video_file: video_file}} ->
          path = Ecto.UUID.generate() <> ".mp4"

          changeset
          |> put_change(:path, path)
          |> put_change(:filename, video_file.filename)

        _ ->
          changeset
      end
    end
  end
end
