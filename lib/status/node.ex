defmodule Status.Node do
  @moduledoc false

  def dependencies do
    with true <- File.exists?("./assets/package.json"),
         {:ok, data} <- File.read("./assets/package.json"),
         {:ok, node_package} <- Poison.decode(data)
    do
      node_modules =
        node_package
        |> Map.get("devDependencies")
        |> Map.merge(Map.get(node_package, "dependencies"))
        |> Enum.map(fn {dep, v} -> {String.to_atom(dep), String.trim_leading(v, "^")} end)
        |> Enum.into(%{})

      %{node: node_modules}
    else
      _ -> %{}
    end
  end

  def outdated do
    with true <- File.exists?("./assets/package.json"),
         {data, 1} <- System.cmd("yarn", ["outdated"], cd: "./assets") do
      %{
        node:
        data
        |> String.split(~r/\n/)
        |> Enum.slice(2..-3)
        |> Enum.map(&List.first(String.split(&1, ~r/\ +/)))
      }
    else
      _ -> %{}
    end
  rescue
    ErlangError -> %{}
  end
end
