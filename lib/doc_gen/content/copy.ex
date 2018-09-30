defmodule DocGen.Content.Copy do
  use Agent

  @moduledoc "Holds the latest settings in memory"

  alias DocGen.Accounts

  ## Client API

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def update do
    Agent.update(__MODULE__, fn _t -> Accounts.get_settings() end)
  end

  ## Server API

  def start_link(_opts) do
    Agent.start_link(&Accounts.get_settings/0, name: __MODULE__)
  end
end
