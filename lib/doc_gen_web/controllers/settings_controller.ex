defmodule DocGenWeb.SettingsController do
  use DocGenWeb, :controller
  use Private

  alias DocGen.{Accounts, Content}

  def index(conn, _params) do
    settings = Accounts.get_settings()
    changeset = Accounts.change_settings(settings)
    video_count = Content.count_videos()
    tags = Content.list_tags()

    # TODO: redo in a private func
    # if video_count < settings.length do
      # put_flash(
        # conn,
        # :error,
        # "There aren't enough videos for #{settings.length} clips!"
      # )
    # else
    conn
    # end
    |> render("index.html", changeset: changeset, settings: settings, tags: tags)
  end

  def update(conn, %{"id" => id, "setting" => setting_params}) do
    case update_setting(id, setting_params) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Settings have been saved.")
        |> redirect(to: Routes.settings_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        settings = Accounts.get_settings()
        render(conn, "index.html", changeset: changeset, settings: settings)
    end
  end

  private do
    # do the database stuff of updating the settings
    @spec update_setting(binary(), %{}) ::
            {:ok, %Accounts.Setting{}} | {:error, Ecto.Changeset.t()}
    defp update_setting(id, attrs) do
      id
      |> String.to_integer()
      |> Accounts.get_setting!()
      |> Accounts.update_setting(attrs)
    end
  end
end
