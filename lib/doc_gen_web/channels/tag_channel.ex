defmodule DocGenWeb.TagChannel do
  use DocGenWeb, :channel
  use Private

  alias DocGen.Content

  def join("tag:lobby", payload, socket) do
    video =
      case payload do
        %{video_id: id} -> Content.get_video!(id, preload: :tags)
        _ -> %{tags: []}
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
      Enum.map(tags, fn t ->
        Map.put(t, :active, t.name in vtags)
      end)
    end
  end
end
