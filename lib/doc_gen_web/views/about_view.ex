defmodule DocGenWeb.AboutView do
  use DocGenWeb, :view

  def title(_, %{title: title}), do: title <> " - About"
end
