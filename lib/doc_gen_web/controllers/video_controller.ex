defmodule DocGenWeb.VideoController do
  use DocGenWeb, :controller
  use Private
  require Logger

  alias DocGen.{Content, Content.Video}

  def index(conn, _params) do
    videos = Content.list_videos()
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params) do
    changeset = Content.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    # _video_names = put_tags(video_params)

    case Content.create_video(video_params) do
      {:ok, video} ->
        persist_file(video, video_params["video_file"])

        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    video = Content.get_video!(id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}) do
    video = Content.get_video!(id)
    changeset = Content.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}) do
    video = Content.get_video!(id)

    case Content.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
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
      video_path = Content.build_video_path(video)

      Logger.debug("Persisting video: #{video_path}")

      unless File.exists?(video_path) do
        video_path
        |> Path.dirname()
        |> File.mkdir_p!()

        File.copy!(temp_path, video_path)
      end
    end

    defp tag_names(video) do
      video
      |> Map.delete("video_file")
      |> Enum.reject(fn {_k, v} -> v == "off" end)
      |> Enum.map(fn {k, _v} -> k end)
    end
  end
end
