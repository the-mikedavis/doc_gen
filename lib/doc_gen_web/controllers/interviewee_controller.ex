defmodule DocGenWeb.IntervieweeController do
  use DocGenWeb, :controller

  alias DocGen.{Content, Content.Interviewee}

  def index(conn, _params) do
    ints = Content.list_interviewees()
    render(conn, "index.html", interviewees: ints)
  end

  def new(conn, _params) do
    changeset = Content.change_interviewee(%Interviewee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"interviewee" => interviewee_params}) do
    case Content.create_interviewee(interviewee_params) do
      {:ok, int} ->
        conn
        |> put_flash(:info, "#{int.name} created successfully.")
        |> redirect(to: Routes.interviewee_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    int = Content.get_interviewee!(id)
    render(conn, "show.html", interviewee: int)
  end

  def edit(conn, %{"id" => id}) do
    int = Content.get_interviewee!(id)
    changeset = Content.change_interviewee(int)
    render(conn, "edit.html", interviewee: int, changeset: changeset)
  end

  def update(conn, %{"id" => id, "interviewee" => interviewee_params}) do
    int = Content.get_interviewee!(id)

    case Content.update_interviewee(int, interviewee_params) do
      {:ok, int} ->
        conn
        |> put_flash(:info, "#{int.name} updated successfully.")
        |> redirect(to: Routes.interviewee_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", interviewee: int, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    int = Content.get_interviewee!(id)
    {:ok, int} = Content.delete_interviewee(int)

    conn
    |> put_flash(:info, "#{int.name} deleted successfully.")
    |> redirect(to: Routes.interviewee_path(conn, :index))
  end
end
