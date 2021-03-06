defmodule DocGenWeb.WatchView do
  use DocGenWeb, :view

  def title(_, %{title: title}), do: title

  def length_text(seconds) do
    minutes = Integer.floor_div(seconds, 60)
    rem_secs = rem(seconds, 60)

    "Total length: #{minutes}:#{rem_secs}."
  end

  def tag_text([tag]) do
    "Topic selected: " <> tag <> "."
  end

  def tag_text(tags) do
    "Topics selected: " <> _tag_text(tags) <> "."
  end

  def _tag_text([]), do: "none"
  def _tag_text([tag]), do: tag

  def _tag_text([tag1, tag2]) do
    tag1 <> " and " <> tag2
  end

  def _tag_text(tags), do: Enum.join(tags, ", ")
end
