defmodule DocGenWeb.TagChannel do
  use DocGenWeb, :channel

  alias DocGen.Content

  def join("tag:lobby", payload, socket) do
    if authorized?(payload) do
      tags = Enum.map(Content.list_tags(), fn %{name: name} -> name end)

      {:ok, %{tags: tags}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_tag", payload, socket) do
    # TODO ?
    # broadcast(socket, "new_tag", payload)
    case Content.create_tag(payload) do
      {:ok, _} ->
        {:reply, {:ok, payload}, socket}
      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  def handle_in("delete_tag", payload, socket) do
    IO.inspect(payload, label: "delete_tag")
    # TODO
    # broadcast(socket, "delete_tag", payload)
    {:reply, {:ok, payload}, socket}
  end

  # TODO
  defp authorized?(_payload) do
    true
  end
end
