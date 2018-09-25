use Mix.Config

config :doc_gen, DocGenWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn
