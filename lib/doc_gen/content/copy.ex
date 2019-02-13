defmodule DocGen.Content.Copy do
  use Agent

  @moduledoc "Holds the latest settings in memory"

  alias DocGen.{Accounts, Accounts.Setting}

  ## Client API

  @spec get(atom()) :: %{} | String.t() | integer()
  def get(:all), do: Agent.get(__MODULE__, & &1)

  def get(key), do: Agent.get(__MODULE__, &Map.get(&1, key))

  def update, do: Agent.update(__MODULE__, fn _t -> load() end)

  ## Server API

  def start_link(_opts) do
    Agent.start_link(&load/0, name: __MODULE__)
  end

  defp load do
    case Accounts.get_settings() do
      %Setting{copy: copy, about: about} = settings ->
        %{settings | copy: parse_markdown(copy), about: parse_markdown(about)}

      nil ->
        %Setting{}
    end
  end

  defp parse_markdown(nil), do: ""

  defp parse_markdown(markdown) when is_binary(markdown),
    do: Earmark.as_html!(markdown)
end
