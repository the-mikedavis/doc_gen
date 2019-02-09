defmodule DocGenWeb.AboutController do
  use DocGenWeb, :controller

  alias DocGen.Content.Copy

  def index(conn, _params) do
    render(conn, "index.html", copy: Copy.get(:about))
  end
end
