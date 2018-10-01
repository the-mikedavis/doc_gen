defmodule DocGenWeb.WatchController do
  use DocGenWeb, :controller
  use Private

  alias DocGen.{Content, Content.Copy, Content.Random}

  plug(:copy when action == :index)
  # TODO: a plug that loads all the videos so they can be put in the top
  # right corner

  def index(conn, _params) do
    tags = Content.list_tags()

    render(conn, "index.html", tags: tags)
  end

  def show(conn, params) do
    tags = parse_tags(params)

    render(conn, "show.html", tags: tags)
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
      |> assign(:length, Integer.floor_div(length, 60))
    end

    @spec parse_tags(%{}) :: [String.t()]
    defp parse_tags(params) do
      params
      |> Enum.reject(fn {k, _v} -> String.starts_with?(k, "_") end)
      |> Enum.filter(fn {_tag_name, on?} -> on? == "on" end)
      |> Enum.map(fn {tag_name, _on?} -> tag_name end)
    end
  end
end
