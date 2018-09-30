defmodule DocGenWeb.Plugs.Title do
  @moduledoc false
  import Plug.Conn

  alias DocGen.Content.Copy

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :title, Copy.get(:title))
  end
end
