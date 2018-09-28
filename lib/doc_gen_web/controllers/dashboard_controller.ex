defmodule DocGenWeb.DashboardController do
  use DocGenWeb, :controller

  def index(conn, _params) do
    # TODO: assign videos and tags and such
    render(conn, "index.html")
  end
end
