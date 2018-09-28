defmodule DocGenWeb.TagChannel do
  use DocGenWeb, :channel

  def join("tag:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_tag", payload, socket) do
    broadcast(socket, "new_tag", payload)
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("delete_tag", payload, socket) do
    broadcast(socket, "delete_tag", payload)
    {:reply, {:ok, payload}, socket}
  end

  # TODO
  defp authorized?(_payload) do
    true
  end
end
