defmodule DocGenWeb.TagChannel do
  use DocGenWeb, :channel

  alias DocGen.Content

  def join("tag:lobby", payload, socket) do
    tags = Enum.map(Content.list_tags(), fn %{name: name} -> name end)

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
end
