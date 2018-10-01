defmodule DocGenWeb.WatchController do
  use DocGenWeb, :controller
  use Private

  alias DocGen.{Content, Content.Copy}

  plug(:copy when action == :index)

  def index(conn, _params) do
    # TODO: assign the cover copy, tags, and videos
    render(conn, "index.html")
  end

  def show(conn, %{"id" => _id}) do
    # TODO show a video
    render(conn, "show.html")
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
  end
end
