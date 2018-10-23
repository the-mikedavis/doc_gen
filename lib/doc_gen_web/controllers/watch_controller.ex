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

    video_ids = Random.give(tags, [b, m, e])

    render(conn, "show.html", tags: tags, video_ids: video_ids)
  end

  def choose(conn, %{"video" => %{"id" => id}}) do
    video = Content.get_video!(id)

    render(conn, "choose.html", video: video)
  end

  def stream(%{req_headers: headers} = conn, %{"id" => id}) do
    video = Content.get_video!(id)

    Content.send_video(conn, headers, video)
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
  end

  def thumb(conn, %{"id" => id}) do
    video = Content.get_video!(id)

    send_file(conn, 200, Content.build_video_path(video) <> ".jpeg")
  end

  def anithumb(conn, %{"id" => id}) do
    video = Content.get_video!(id)

    send_file(conn, 200, Content.build_video_path(video) <> ".gif")
  end
end
