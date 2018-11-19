defmodule DocGenWeb.VideoController do
  use DocGenWeb, :controller
  use Private
  require Logger

  alias DocGen.{Content, Content.Video}

  def index(conn, _params) do
    videos = Content.list_videos_with_interviewees()
    render(conn, "index.html", videos: videos, csrf_token: get_csrf_token())
  end

  def new(conn, _params) do
    changeset = Content.change_video(%Video{})
    ints = Content.list_interviewees()
    types = Content.list_types()
    segs = Content.list_segments()

    render(conn, "new.html",
      changeset: changeset,
      interviewees: ints,
      types: types,
      segments: segs
    )
  end

  def create(conn, %{"video" => video_params}) do
    video_params = put_tags(video_params)

    case Content.create_video(video_params) do
      {:ok, video} ->
        video
        |> persist_file(video_params["video_file"])
        |> update_duration(video)

        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: Routes.video_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        ints = Content.list_interviewees()
        types = Content.list_types()
        segs = Content.list_segments()

        render(conn, "new.html",
          changeset: changeset,
          interviewees: ints,
          types: types,
          segments: segs
        )
    end
  end

  def show(conn, %{"id" => id}) do
    video = Content.get_video!(id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}) do
    video = Content.get_video!(id, preload: true)
    changeset = Content.change_video(video)
    ints = Content.list_interviewees()
    types = Content.list_types()
    segs = Content.list_segments()

    conn
    |> put_layout(:frame)
    |> render("edit.html",
      video: video,
      changeset: changeset,
      interviewees: ints,
      types: types,
      segments: segs
    )
  end

  def update(conn, %{"id" => id, "video" => video_params}) do
    video = Content.get_video!(id, preload: true)
    video_params = put_tags(video_params)

    case Content.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video saved successfully.")
        |> redirect(to: Routes.video_path(conn, :edit, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        ints = Content.list_interviewees()

        render(conn, "edit.html",
          video: video,
          changeset: changeset,
          interviewees: ints
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    video = Content.get_video!(id)
    {:ok, _video} = Content.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: Routes.video_path(conn, :index))
  end

  private do
    # save the file to a path
    defp persist_file(video, %{path: temp_path}) do
      # get the absolute path to the file
      video_path = Content.build_video_path(video)

      Logger.debug(fn -> "Persisting video: #{video_path}" end)

      unless File.exists?(video_path) do
        video_path
        |> Path.dirname()
        |> File.mkdir_p!()

        File.copy!(temp_path, video_path)

        Thumbnex.animated_gif_thumbnail(video_path, video_path <> ".gif")
        Thumbnex.create_thumbnail(video_path, video_path <> ".jpeg")
      end

      {:ok, video_path}
    end

    defp persist_file(_, _) do
      Logger.error(fn -> "Could not persist video file" end)

      :error
    end

    @spec put_tags(%{}) :: %{}
    defp put_tags(video_params) do
      tags =
        video_params
        |> Map.delete("video_file")
        |> Enum.filter(fn {_tag_name, on?} -> on? == "on" end)
        |> Enum.map(fn {tag_name, _on?} ->
          tag_name
          |> String.replace("%22", "")
          |> Content.get_tag_by_name!()
        end)

      Map.put(video_params, "tags", tags)
    end

    defp update_duration({:ok, video_path}, video) do
      duration =
        video_path
        |> FFprobe.duration()
        |> round()

      Content.update_video(video, %{duration: duration})
    end

    defp update_duration(_, _), do: :ok
  end
end
