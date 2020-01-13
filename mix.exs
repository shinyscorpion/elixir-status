defmodule Status.Mixfile do
  use Mix.Project

  def project do
    [
      app: :status,
      version: "0.1.1",
      description: "Application status reports",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "status",
      source_url: "https://github.com/shinyscorpion/elixir-status",
      homepage_url: "https://github.com/shinyscorpion/elixir-status",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def package do
    [
      name: :status,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/status",
        "lib/status.ex",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/shinyscorpion/elixir-status"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
