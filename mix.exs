defmodule ProjectStatus.Mixfile do
  use Mix.Project

  def project do
    [app: :project_status,
     version: "0.0.5",
     elixir: "~> 1.1.1",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {ProjectStatus, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :postgrex,
                    :chronos, :mailgun, :earmark, :exrm, :basic_auth, :ssl]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.0.3"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:cowboy, "~> 1.0"},
     {:chronos, "~> 1.4.0"},
     {:mailgun, "~> 0.1.1"},
     {:earmark, "~> 0.1.17"},
     {:exrm, "~> 0.19.6"},
     {:basic_auth, "~> 1.0.0"},
     {:mock, ">= 0.0.0"}]
  end
end
