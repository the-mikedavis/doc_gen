defmodule DocGen.Application do
  @moduledoc false

  use Application

  alias DocGen.Content

  def start(_type, _args) do
    children = [
      DocGen.Repo,
      DocGenWeb.Endpoint,
      {DocGen.Content.Copy, []}
    ]

    opts = [strategy: :one_for_one, name: DocGen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:create_dirs, _, _) do
    [Content.upload_dir()]
    |> Enum.each(&File.mkdir_p!/1)

    :ok
  end

  def config_change(changed, _new, removed) do
    DocGenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
