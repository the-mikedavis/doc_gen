defmodule DocGen.Content do
  use Private
  import Ecto.Query, warn: false
  alias DocGen.Repo
  alias DocGen.Content.{Embed, Interviewee, Segment, Tag, Type, Video}

  @moduledoc """
  The Content context.
  """

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Repo.all(Video)
  end

  def list_videos_with_interviewees do
    Repo.all(from(v in Video, select: v, preload: :interviewee))
  end

  def list_videos_with_all do
    Repo.all(
      from(v in Video,
        select: v,
        preload: [:interviewee, :segment, :tags, :type]
      )
    )
  end

  @spec count_videos() :: non_neg_integer()
  def count_videos, do: Repo.aggregate(Video, :count, :id)

  def get_video!(id, opts \\ [])

  def get_video!(id, preload: :tags) do
    Repo.one(from(v in Video, select: v, where: [id: ^id], preload: :tags))
  end

  def get_video!(id, preload: true) do
    Repo.one(
      from(v in Video,
        select: v,
        where: [id: ^id],
        preload: [:interviewee, :segment, :tags, :type]
      )
    )
  end

  def get_video!(id, _opts), do: Repo.get(Video, id)

  def get_video(id, opts \\ [])

  def get_video(id, preload: :tags) do
    Repo.one(from(v in Video, select: v, where: [id: ^id], preload: :tags))
  end

  def get_video(id, preload: true) do
    Repo.one(
      from(v in Video,
        select: v,
        where: [id: ^id],
        preload: [:interviewee, :segment, :tags, :type]
      )
    )
  end

  def get_video(id, _opts), do: Repo.get(Video, id)

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(%{field: value})
      {:ok, %Video{}}

      iex> create_video(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    delete_video_files(video)

    Repo.delete(video)
  end

  @spec delete_video_files(%Video{}) :: [:ok | {:error, any()}]
  defp delete_video_files(%Video{} = video) do
    (build_video_path(video) <> "*")
    |> Path.wildcard()
    |> Enum.each(&File.rm!/1)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{source: %Video{}}

  """
  def change_video(%Video{} = video) do
    Video.changeset(video, %{})
  end

  def upload_dir do
    Path.join("#{:code.priv_dir(:doc_gen)}", "uploads")
  end

  @doc """
  Provide a path given a video.
  """
  @spec build_video_path(%Video{}) :: Path.t()
  def build_video_path(%Video{path: path}) do
    Path.join(upload_dir(), path)
  end

  @doc """
  Send a video out of a socket.
  """
  @spec send_video(Plug.Conn.t(), Keyword.t(), %Video{}) :: Plug.Conn.t()
  def send_video(conn, headers, video) do
    video_path = build_video_path(video)
    offset = get_offset(headers)
    file_size = get_file_size(video_path)

    conn
    |> Plug.Conn.put_resp_header("content-type", video.content_type)
    |> Plug.Conn.put_resp_header(
      "content-range",
      "bytes #{offset}-#{file_size - 1}/#{file_size}"
    )
    |> Plug.Conn.send_file(206, video_path, offset, file_size - offset)
  end

  private do
    @spec get_offset(Keyword.t()) :: non_neg_integer()
    defp get_offset(headers) do
      case List.keyfind(headers, "range", 0) do
        {"range", "bytes=" <> start_pos} ->
          start_pos
          |> String.split("-")
          |> List.first()
          |> String.to_integer()

        _ ->
          0
      end
    end

    @spec get_file_size(Path.t()) :: non_neg_integer()
    defp get_file_size(path) do
      %{size: size} = File.stat!(path)

      size
    end
  end

  ## Tags stuff
  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  def get_tag_by_name!(name), do: Repo.get_by!(Tag, name: name)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  ## Combined stuff, tags and videos
  def list_tags_with_videos do
    Tag
    |> Repo.all()
    |> Enum.map(&Repo.preload(&1, :videos))
  end

  @doc """
  Returns the list of interviewees.

  ## Examples

      iex> list_interviewees()
      [%Interviewee{}, ...]

  """
  def list_interviewees do
    Repo.all(Interviewee)
  end

  def change_interviewee(%Interviewee{} = int),
    do: Interviewee.changeset(int, %{})

  def create_interviewee(attrs \\ %{}) do
    %Interviewee{}
    |> Interviewee.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Creates a interviewee."
  def create_interviewee!(attrs \\ %{}) do
    %Interviewee{}
    |> Interviewee.changeset(attrs)
    |> Repo.insert!()
  end

  def get_interviewee!(id), do: Repo.get!(Interviewee, id)

  @doc """
  Tries to get an interviewee by name. If not available, creates that
  interviewee.
  """
  def get_or_create_interviewee(name) do
    case Repo.get_by(Interviewee, name: name) do
      %Interviewee{} = interviewee ->
        interviewee

      nil ->
        create_interviewee!(%{name: name})
    end
  end

  def update_interviewee(%Interviewee{} = int, attrs) do
    int
    |> Interviewee.changeset(attrs)
    |> Repo.update()
  end

  def delete_interviewee(%Interviewee{} = int), do: Repo.delete(int)

  def get_type(id), do: Repo.get(Type, id)

  def list_types do
    Repo.all(Type)
  end

  def get_segment(id), do: Repo.get(Segment, id)

  def list_segments do
    Repo.all(Segment)
  end

  def list_segments_with_videos do
    Repo.all(from(s in Segment, select: s, preload: :videos))
  end

  def list_embeds, do: Repo.all(Embed)

  def get_embed!(id), do: Repo.get!(Embed, id)

  def create_embed(attrs \\ %{}) do
    %Embed{}
    |> Embed.changeset(attrs)
    |> Repo.insert()
  end

  def delete_embed(%Embed{} = embed), do: Repo.delete(embed)

  def change_embed(%Embed{} = embed), do: Embed.changeset(embed, %{})
end
