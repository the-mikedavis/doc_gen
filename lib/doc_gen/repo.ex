defmodule DocGen.Repo do
  use Ecto.Repo,
    otp_app: :doc_gen,
    adapter: Ecto.Adapters.Postgres
end
