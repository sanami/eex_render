defmodule EexRender.MixProject do
  use Mix.Project

  def project do
    [
      app: :eex_render,
      version: "0.1.1",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      description: "A view engine for rendering EEx templates.",
      deps: deps(),
      name: "EExRender",
      source_url: "https://github.com/sanami/eex_render",
      package: [
        name: "eex_render",
        files: ["lib", "mix.exs", "README.md", "LICENSE"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/sanami/eex_render"}
      ]
    ]
  end

  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.12"},
      {:nimble_options, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
