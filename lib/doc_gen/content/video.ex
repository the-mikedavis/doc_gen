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
    field(:weight, :integer, default: 1)
    many_to_many(:tags, Tag, join_through: "videos_tags", on_replace: :delete)
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
      :interviewee,
      :weight
    ])
    |> put_tags(attrs)
    |> foreign_key_constraint(:type_id)
    |> validate_required([:video_file])
    |> validate_number(:weight, greater_than: 0)
    |> unique_constraint(:filename)
    |> put_video_file()
  end

  private do
    defp put_tags(changeset, %{tags: [_|_] = tags}) do
      put_assoc(changeset, :tags, tags)
    end

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
