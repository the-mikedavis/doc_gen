use Mix.Config

config :doc_gen, DocGenWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :doc_gen, DocGen.Repo,
  username: "postgres",
  password: "postgres",
  database: "doc_gen_test",
  pool: Ecto.Adapters.SQL.Sandbox
