defmodule DocGenWeb.VideoView do
  use DocGenWeb, :view

  def title(_, _), do: "Doc-Gen: Dashboard"

  def duration(seconds) do
    minutes = Integer.floor_div(seconds, 60)
    rem_secs = rem(seconds, 60)

    "#{minutes}:#{rem_secs}"
  end

  def type_select(types) do
    Enum.map(types, fn t -> {String.to_atom(t.name), t.id} end)
  end
end
