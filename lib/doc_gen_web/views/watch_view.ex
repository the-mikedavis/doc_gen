defmodule DocGenWeb.WatchView do
  use DocGenWeb, :view

  def title(_, %{title: title}), do: title
end
