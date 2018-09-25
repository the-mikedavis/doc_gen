use Mix.Config

config :doc_gen,
  ecto_repos: [DocGen.Repo]

config :doc_gen, DocGenWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "Pb0S1nsqJf1VVTKNVlPyIoPzyAnrP/RQk8XnMeAP88x39z2f5l8AGsEQMmsEJS+y",
  render_errors: [view: DocGenWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DocGen.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
config :ecto, :json_library, Jason

import_config "#{Mix.env()}.exs"
