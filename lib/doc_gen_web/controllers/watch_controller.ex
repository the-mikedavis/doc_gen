defmodule DocGenWeb.WatchController do
  use DocGenWeb, :controller
  use Private

  alias DocGen.{Accounts, Content, Content.Copy, Content.Random}

  plug(:copy when action == :index)
  plug(:load_videos when action in [:index, :show])
  # TODO: a plug that loads all the videos so they can be put in the top
  # right corner

  def index(conn, _params) do
    tags = Content.list_tags()

    render(conn, "index.html", tags: tags)
  end

  def show(conn, params) do
    tags = parse_tags(params)
    settings = Accounts.get_settings()
    video_ids = Random.give(tags, settings.length)

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
      %{copy: copy, length: length} = Copy.get(:all)

      conn
      |> assign(:copy, copy)
      |> assign(:length, length)
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
end
