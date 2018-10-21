defmodule DocGenWeb.TagChannel do
  use DocGenWeb, :channel
  use Private

  @moduledoc "The tag channel used by LiveTags.elm"

  alias DocGen.Content

  def join("tag:lobby", %{"video_id" => id}, socket) do
    video =
      case Content.get_video(id, preload: :tags) do
        nil -> %{tags: []}
        video -> video
      end

    tags =
      Content.list_tags()
      |> Enum.map(&Map.take(&1, [:name, :weight]))
      |> activate_tags(video)

    {:ok, %{tags: tags}, socket}
  end

  def handle_in("new_tag", payload, socket) do
    case Content.create_tag(payload) do
      {:ok, _tag} ->
        {:reply, {:ok, payload}, socket}

      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  def handle_in("delete_tag", %{"name" => name} = payload, socket) do
    name
    |> Content.get_tag_by_name!()
    |> Content.delete_tag()

    {:reply, {:ok, payload}, socket}
  end

  private do
    defp activate_tags(tags, %{tags: vtags}) do
      vtagnames = Enum.map(vtags, & &1.name)

      Enum.map(tags, fn t ->
        Map.put(t, :active, t.name in vtagnames)
      end)
    end
  end
end
