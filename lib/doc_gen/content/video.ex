defmodule DocGen.Content.Video do
  use Ecto.Schema
  use Private
  import Ecto.Changeset

  alias DocGen.Content.{Tag, Type}

  @moduledoc """
  The Video context.
  """

  schema "videos" do
    field(:video_file, :any, virtual: true)
    field(:filename, :string)
    field(:content_type, :string)
    field(:path, :string)
    field(:interviewee, :string)
    has_many(:tags, Tag)
    belongs_to(:type, Type)

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [
      :path,
      :video_file,
      :filename,
      :interviewee
    ])
    |> foreign_key_constraint(:type_id)
    |> foreign_key_constraint(:tags)
    |> validate_required([:video_file])
    |> unique_constraint(:filename)
    |> put_video_file()
  end

  private do
    defp put_video_file(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{video_file: video_file}} ->
          path = Ecto.UUID.generate() <> Path.extname(video_file.filename)

          changeset
          |> put_change(:path, path)
          |> put_change(:filename, video_file.filename)
          |> put_change(:content_type, video_file.content_type)

        _ ->
          changeset
      end
    end
  end
end
