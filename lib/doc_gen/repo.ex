defmodule DocGen.Repo do
  use Ecto.Repo,
    otp_app: :doc_gen,
    adapter: Ecto.Adapters.Postgres

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
