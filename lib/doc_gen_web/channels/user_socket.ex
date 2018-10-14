defmodule DocGenWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel("tag:*", DocGenWeb.TagChannel)
  channel("video:*", DocGenWeb.VideoChannel)

  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, socket_token_key(), token, max_age: 1209600) do
      {:ok, user_id} ->
        {:ok, assign(socket, :current_user, user_id)}
      {:error, _reason} ->
        :error
    end
  end

  def id(_socket), do: nil

  defp socket_token_key, do: Application.get_env(:doc_gen, :socket_token_key)
end
