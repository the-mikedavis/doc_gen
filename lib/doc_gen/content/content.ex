defmodule DocGen.Content do
  use Private

  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias DocGen.Repo

  alias DocGen.Content.Video

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Repo.all(Video)
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: Repo.get!(Video, id)

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
    Repo.delete(video)
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
      case Keyword.fetch(headers, "range") do
        {:ok, "bytes=" <> start_pos} ->
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
end
