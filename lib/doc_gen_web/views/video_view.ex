defmodule DocGenWeb.VideoView do
  use DocGenWeb, :view

  def title(_, _), do: "Doc-Gen: Dashboard"

  def duration(seconds) do
    minutes = Integer.floor_div(seconds, 60)
    rem_secs = rem(seconds, 60)

    "#{minutes}:#{rem_secs}"
  end
end
