defmodule DocGen.MixProject do
  use Mix.Project

  def project do
    [
      app: :doc_gen,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        bless: :test,
        coveralls: :test,
        "coveralls.html": :test,
        credo: :test,
        dialyzer: :test
      ],
      dialyzer: [ignore_warnings: ".dialyzer.ignore_warnings"]
    ]
  end

  def application do
    [
      mod: {DocGen.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix things
      {:phoenix, github: "phoenixframework/phoenix", override: true},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:cowboy, "~> 1.0"},
      # Slim HTML
      {:phoenix_slime, "~> 0.10"},
      # Auth
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 1.0"},
      # testing, cleanliness, etc.
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.9", only: :test},
      {:mox, "~> 0.3"},
      {:private, "~> 0.1.1"},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      # deploying
      {:distillery, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      bless: [&bless/1]
    ]
  end

  defp bless(_) do
    [
      {"compile", ["--warnings-as-errors", "--force"]},
      {"coveralls.html", []},
      {"format", ["--check-formatted"]},
      {"credo", []},
      {"dialyzer", []}
    ]
    |> Enum.each(fn {task, args} ->
      IO.ANSI.format([:cyan, "Running #{task} with args #{inspect(args)}"])
      |> IO.puts()

      Mix.Task.run(task, args)
    end)
  end
end
