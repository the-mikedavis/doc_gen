defmodule DocGenWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel("tag:*", DocGenWeb.TagChannel)

  def connect(_params, socket, _connect_info) do
    # TODO: authenticate as in mole

    {:ok, socket}
  end

  def id(_socket), do: nil
end
