defmodule DocGen.Content.Video do
  use Ecto.Schema
  use Private
  import Ecto.Changeset

  alias DocGen.Content
  alias DocGen.Content.{Interviewee, Segment, Tag, Type}

  @moduledoc """
  The Video context.
  """

  schema "videos" do
    field(:video_file, :any, virtual: true)
    field(:filename, :string)
    field(:content_type, :string)
    field(:path, :string)
    field(:title, :string)
    field(:duration, :integer, default: 0)

    many_to_many(:tags, Tag,
      join_through: "videos_tags",
      on_replace: :delete,
      on_delete: :delete_all
    )

    belongs_to(:type, Type)
    belongs_to(:interviewee, Interviewee)
    belongs_to(:segment, Segment)
    field(:interviewee_name, :string, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [
      :path,
      :video_file,
      :filename,
      :title,
      :duration,
      :interviewee_name,
      :type_id,
      :segment_id
    ])
    |> put_tags(attrs)
    |> foreign_key_constraint(:type_id)
    |> put_type()
    |> foreign_key_constraint(:segment_id)
    |> foreign_key_constraint(:interviewee_id)
    |> unique_constraint(:title)
    |> put_interviewee()
    |> put_video_file()
    |> validate_required(:path)
  end

  private do
    defp put_tags(changeset, %{"tags" => [_ | _] = tags}) do
      put_assoc(changeset, :tags, tags)
    end

    defp put_tags(changeset, %{tags: [_ | _] = tags}) do
      put_assoc(changeset, :tags, tags)
    end

    defp put_tags(changeset, _), do: changeset

    defp put_type(
           %Ecto.Changeset{valid?: true, changes: %{type_id: id}} = changeset
         ) do
      put_change(changeset, :type, Content.get_type(id))
    end

    defp put_type(changeset), do: changeset

    defp put_interviewee(changeset) do
      case changeset do
        %Ecto.Changeset{valid?: true, changes: %{interviewee_name: iv_name}} ->
          interviewee = Content.get_or_create_interviewee(iv_name)
          put_change(changeset, :interviewee_id, interviewee.id)

        _ ->
          changeset
      end
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
