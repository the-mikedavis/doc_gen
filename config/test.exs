use Mix.Config

config :doc_gen, DocGenWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :doc_gen,
  socket_token_key:
    "Wi5M0udtBDHSHa2B6S4jt0j7WhkJw7PELa+w6V1W09odfIWrSOKBCye0FnFKzB/Z"

config :doc_gen, DocGen.Repo,
  username: "postgres",
  password: "postgres",
  database: "doc_gen_test",
  pool: Ecto.Adapters.SQL.Sandbox
