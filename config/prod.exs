use Mix.Config

config :doc_gen, DocGenWeb.Endpoint,
  http: [:inet6, port: "${DOC_GEN_PORT}"],
  url: [host: "${DOC_GEN_HOST}"],
  secret_key_base: "${DOC_GEN_SECRET_KEYBASE}",
  cache_static_manifest: "priv/static/cache_manifest.json"

config :doc_gen,
  socket_token_key: "${DOC_GEN_SOCKET_TOKEN_KEY}"

config :logger, level: :info

config :doc_gen, DocGen.Repo,
  username: "${DOC_GEN_DB_USERNAME}",
  password: "${DOC_GEN_DB_PASSWORD}",
  database: "${DOC_GEN_DB_DATABASE}",
  pool_size: 15
