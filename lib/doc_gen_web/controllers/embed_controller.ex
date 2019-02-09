defmodule DocGenWeb.EmbedController do
  use DocGenWeb, :controller

  alias DocGen.Content
  alias Content.Embed

  def index(conn, _params) do
    embeds = Content.list_embeds()

    render(conn, "index.html", embeds: embeds)
  end

  def all(conn, _params) do
    embeds = Content.list_embeds()

    render(conn, "all.html", embeds: embeds)
  end

  def new(conn, _params) do
    changeset = Content.change_embed(%Embed{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"embed" => embed_params}) do
    case Content.create_embed(embed_params) do
      {:ok, embed} ->
        conn
        |> put_flash(:info, "Embed created successfully.")
        |> redirect(to: Routes.embed_path(conn, :show, embed))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    embed = Content.get_embed!(id)
    render(conn, "show.html", embed: embed)
  end

  def delete(conn, %{"id" => id}) do
    embed = Content.get_embed!(id)
    {:ok, _embed} = Content.delete_embed(embed)

    conn
    |> put_flash(:info, "Embed deleted successfully.")
    |> redirect(to: Routes.embed_path(conn, :index))
  end
end
