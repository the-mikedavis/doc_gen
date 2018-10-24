defmodule DocGenWeb.VideoChannel do
  use DocGenWeb, :channel

  @moduledoc "The video channel used by Dashboard.elm"

  alias DocGen.{Content, Content.Video}

  def join("video:lobby", _payload, socket) do
    {:ok, %{videos: videos()}, socket}
  end

  def handle_in("videos", _, socket) do
    {:reply, {:ok, %{videos: videos()}}, socket}
  end

  @fields [:tags, :type, :interviewee, :path, :title, :id, :duration, :segment]

  defp simplify_video(%Video{} = video) do
    video
    |> Map.from_struct()
    |> Map.take(@fields)
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.put(acc, k, simplify_preloads(k, v))
    end)
  end

  defp change_type_key(%{type: type} = video_map) do
    video_map
    |> Map.delete(:type)
    |> Map.put(:clip_type, type)
  end

  @preloads [:tags, :type, :interviewee, :segment]

  defp simplify_preloads(key, value) when key not in @preloads do
    value
  end

  defp simplify_preloads(_key, values) when is_list(values) do
    Enum.map(values, fn %{name: name} -> name end)
  end

  defp simplify_preloads(_key, nil), do: ""
  defp simplify_preloads(_key, value), do: value.name

  defp videos() do
    videos =
      Content.list_videos_with_all()
      |> Enum.map(&simplify_video/1)
      |> Enum.map(&change_type_key/1)

    videos
  end
end
