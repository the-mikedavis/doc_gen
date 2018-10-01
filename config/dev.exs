use Mix.Config

config :doc_gen, DocGenWeb.Endpoint,
  http: [port: 4000],
  url: [host: "galactica.relaytms.com"],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :doc_gen, DocGenWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/doc_gen_web/views/.*(ex)$},
      ~r{lib/doc_gen_web/templates/.*(eex|slim)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :doc_gen, DocGen.Repo,
  username: "postgres",
  password: "postgres",
  database: "doc_gen_dev",
  hostname: "localhost",
  pool_size: 10
