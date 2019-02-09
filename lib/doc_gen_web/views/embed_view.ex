defmodule DocGenWeb.EmbedView do
  use DocGenWeb, :view

  def title(_, %{title: title}), do: title <> " - Full Interviews"
end
