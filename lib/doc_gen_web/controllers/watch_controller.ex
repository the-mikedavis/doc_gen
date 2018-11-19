defmodule DocGenWeb.WatchController do
  use DocGenWeb, :controller
  use Private

  alias DocGen.{Accounts, Content, Content.Copy, Content.Random}

  plug(:copy when action == :index)
  plug(:load_videos when action in [:index, :show])

  def index(conn, _params) do
    tags = Content.list_tags()

    render(conn, "index.html", tags: tags)
  end

  def show(conn, params) do
    tags = parse_tags(params)

    %{beginning_clips: b, middle_clips: m, end_clips: e} =
      Accounts.get_settings()

    {video_ids, length} = Random.give(tags, [b, m, e])

    conn
    |> put_preloads(video_ids)
    |> render("show.html", tags: tags, video_ids: video_ids, length: length)
  end

  def choose(conn, %{"video" => %{"id" => id}}) do
    video = Content.get_video!(id)

    render(conn, "choose.html", video: video)
  end

  def stream(%{req_headers: headers} = conn, %{"id" => id}) do
    video = Content.get_video!(id)

    Content.send_video(conn, headers, video)
  end

  def thumb(conn, %{"id" => id}) do
    video = Content.get_video!(id)

    send_file(conn, 200, Content.build_video_path(video) <> ".jpeg")
  end

  # animated thumb
  def anithumb(conn, %{"id" => id}) do
    video = Content.get_video!(id)

    send_file(conn, 200, Content.build_video_path(video) <> ".gif")
  end

  private do
    defp copy(conn, _opts) do
      %{copy: copy, beginning_clips: b, middle_clips: m, end_clips: e} =
        Copy.get(:all)

      conn
      |> assign(:copy, copy)
      |> assign(:length, b + m + e)
    end

    defp load_videos(conn, _opts) do
      assign(conn, :videos, Content.list_videos())
    end

    @spec parse_tags(%{}) :: [String.t()]
    defp parse_tags(params) do
      params
      |> Enum.reject(fn {k, _v} -> String.starts_with?(k, "_") end)
      |> Enum.filter(fn {_tag_name, on?} -> on? == "on" end)
      |> Enum.map(fn {tag_name, _on?} -> tag_name end)
    end

    defp put_preloads(%{resp_headers: headers} = conn, ids) do
      preloads =
        ids
        |> Enum.map(&preload_link(conn, &1))
        |> Enum.map(fn header -> {"link", header} end)

      %{conn | resp_headers: headers ++ preloads}
    end

    defp preload_link(conn, video_id) do
      Routes.watch_path(conn, :stream, video_id) <> "; rel=preload; as=video"
    end
  end
end
