defmodule DocGen.Content.Copy do
  use Agent

  @moduledoc "Holds the latest settings in memory"

  alias DocGen.Accounts

  ## Client API

  @spec get(atom()) :: %{} | String.t() | integer()
  def get(:all), do: Agent.get(__MODULE__, & &1)

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def update do
    Agent.update(__MODULE__, fn _t ->
      settings = Accounts.get_settings()

      %{
        settings
        | copy: Earmark.as_html!(settings.copy),
          about: Earmark.as_html!(settings.about)
      }
    end)
  end

  ## Server API

  def start_link(_opts) do
    Agent.start_link(&Accounts.get_settings/0, name: __MODULE__)
  end
end
