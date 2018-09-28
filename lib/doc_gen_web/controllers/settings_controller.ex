defmodule DocGenWeb.SettingsController do
  use DocGenWeb, :controller

  def index(conn, _params) do
    # TODO: do some magin here with settings
    render(conn, "index.html")
  end
end
