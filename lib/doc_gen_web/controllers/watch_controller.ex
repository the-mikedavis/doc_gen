defmodule DocGenWeb.WatchController do
  use DocGenWeb, :controller

  alias DocGen.Content

  def show(%{req_headers: headers} = conn, %{"id" => id}) do
    video = Content.get_video!(id)

    Content.send_video(conn, headers, video)
  end
end
