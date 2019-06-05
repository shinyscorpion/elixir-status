defmodule Status.Elixir do
  @moduledoc false

  def dependencies do
    %{
      elixir:
        :application_controller.which_applications()
        |> Enum.map(fn {dep, _desc, v} -> {dep, to_string(v)} end)
        |> Enum.into(%{})
    }
  end

  def outdated do
    lock = Mix.Dep.Lock.read()

    deps =
      []
      |> Mix.Dep.load_on_environment()
      |> Enum.filter(&(&1.scm == Hex.SCM))
      |> Enum.filter(& &1.top_level)

    Hex.Registry.Server.open()

    Hex.Mix.packages_from_lock(lock)
    |> Hex.Registry.Server.prefetch()

    elixir_outdated =
      deps
      |> Enum.reject(fn dep ->
        %{repo: repo, name: package, version: lock_version} = Hex.Utils.lock(lock[dep.app])

        repo
        |> Hex.Registry.Server.versions(package)
        |> List.last()
        |> Kernel.==(lock_version)
      end)
      |> Enum.map(& &1.app)

    %{elixir: elixir_outdated}
  end
end
