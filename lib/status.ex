defmodule Status do
  @moduledoc false

  @options [
    commit: {true, &Status.System.commit/0},
    timestamp: [
      {true, &Status.Time.deploy/0},
      {false, &Status.Time.build/0},
    ],
    uptime: {true, &Status.Time.uptime/0},
    version: {false, &Status.System.commit/0},
    system: [
      {true, &Status.System.version/0},
      {false, &Status.System.version_tools/0},
    ],
    dependencies: [
      {true, &Status.Elixir.dependencies/0},
      {false, &Status.Node.dependencies/0},
    ],
    outdated: [
      {false, &Status.Elixir.outdated/0},
      {false, &Status.Node.outdated/0},
    ],
  ]
  @default [
    :commit,
    :uptime,
    :timestamp,
    :system,
    :dependencies,
    :outdated,
  ]

  defp runtime_sub_group({true, value}, {runtimes, compiles}),
    do: {[value | runtimes], compiles}
  defp runtime_sub_group({false, value}, {runtimes, compiles}),
    do: {runtimes, [value.() | compiles]}

  defp runtime_group(value, {runtimes, compiles}) do
    case @options[value] do
      grouped when is_list(grouped) ->
        {r, c} = Enum.reduce(grouped, {[], []}, &runtime_sub_group/2)
        {[{value, r} | runtimes], [{value, c} | compiles]}
      {true, func} ->
        {[{value, func} | runtimes], compiles}
      {false, func} ->
        {runtimes, [{value, func.()} | compiles]}
      nil ->
        {runtimes, compiles}
    end
  end

  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end

  defp deep_resolve(_key, _left, right) do
    right
  end

  defp create_status(values) do
    {runtime, compile_time} =
      values
      |> Enum.reduce({[], []}, &runtime_group/2)

    compiled_values =
      compile_time
      |> Enum.reduce(%{}, fn
          {k, v}, acc when is_list(v) -> Map.put(acc, k, Enum.reduce(v, &Map.merge/2))
          {k, v}, acc -> Map.put(acc, k, v)
         end)
      |> Macro.escape()

    quote do
      Enum.reduce(
        unquote(runtime),
        %{},
        fn
          {k, v}, acc when is_list(v) ->
            Map.put(acc, k, v |> Enum.map(& &1.()) |> Enum.reduce(%{}, &Map.merge/2))
          {k, v}, acc ->
            Map.put(acc, k, v.())
        end
      )
      |> Status.deep_merge(unquote(compiled_values))
    end
  end

  defmacro map(values \\ @default) do
    create_status(values)
  end
  defmacro json(values \\ @default) do
    x = create_status(values)
    quote do
      unquote(x)
      |> Poison.encode(pretty: true)
    end
  end
  defmacro json!(values \\ @default) do
    x = create_status(values)
    quote do
      unquote(x)
      |> Poison.encode!(pretty: true)
    end
  end
end
