defmodule Status.System do
  @moduledoc false

  @cmd_options [stderr_to_stdout: true]
  def commit do
    with {sha, 0} <- System.cmd("git", ~w(rev-parse HEAD), @cmd_options) do
      String.trim_trailing(sha)
    else
      _ -> System.get_env("GIT_COMMIT") || "no commit given"
    end
  rescue
    ErlangError -> System.get_env("GIT_COMMIT") || "no commit given"
  end

  def version do
    %{
      elixir: System.version(),
      erts: to_string(:erlang.system_info(:version)),
      otp: to_string(:erlang.system_info(:otp_release))
    }
  end

  def version_tools do
    [
      node: nodejs(),
      yarn: yarn()
    ]
    |> Enum.filter(fn {_, v} -> v end)
    |> Enum.into(%{})
  end

  ### Helpers

  defp nodejs do
    with {version, 0} <- System.cmd("node", ["--version"], @cmd_options) do
      version
      |> String.trim_leading("v")
      |> String.trim_trailing()
    else
      _ -> false
    end
  rescue
    ErlangError -> false
  end

  defp yarn do
    with {version, 0} <- System.cmd("yarn", ["--version"], @cmd_options) do
      version
      |> String.trim_leading("v")
      |> String.trim_trailing()
    else
      _ -> false
    end
  rescue
    ErlangError -> false
  end
end
