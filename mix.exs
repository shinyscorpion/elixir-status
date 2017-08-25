defmodule Status.Mixfile do
  use Mix.Project

  def project do
    [
      app: :status,
      version: "0.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "status",
      source_url: "https://github.com/shinyscorpion/elixir-status",
      homepage_url: "https://github.com/shinyscorpion/elixir-status",
      docs: [
        main: "readme",
        extras: ["README.md", "LICENSE"],
      ],
    ]
  end

  def package do
    [
      name: :status,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        "lib/status", "lib/status.ex", "mix.exs", "README*", "LICENSE*", # Elixir
      ],
      links: %{
        "GitHub" => "https://github.com/shinyscorpion/elixir-status",
      },
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
    ]
  end
end
