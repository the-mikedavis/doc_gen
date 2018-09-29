defmodule DocGenWeb.WatchController do
  use DocGenWeb, :controller

  alias DocGen.Content

  def index(conn, _params) do
    # TODO: assign the cover copy, tags, and videos
    render(conn, "index.html")
  end

  def show(%{req_headers: headers} = conn, %{"id" => id}) do
    video = Content.get_video!(id)

    Content.send_video(conn, headers, video)
  end
end
