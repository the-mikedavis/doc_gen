defmodule DocGenWeb.WatchController do
  use DocGenWeb, :controller

  alias DocGen.Content

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
end
