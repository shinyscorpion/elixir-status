defmodule Status.Time do
  @moduledoc false

  def deploy do
    {utime, _} = :erlang.statistics(:wall_clock)

    deploy =
      :milli_seconds
      |> :os.system_time()
      |> Kernel.-(utime)
      |> DateTime.from_unix!(:milli_seconds)

    %{
      deploy: deploy,
      now: DateTime.utc_now(),
    }
  end

  def build do
    %{
      build: DateTime.utc_now(),
    }
  end

  def uptime(options \\ [as: :string]) do
    {utime, _} = :erlang.statistics(:wall_clock)

    if options[:as] == :string do
      sec_to_str(utime)
    else
      utime
    end
  end

  ### Helpers ###

  @second 1000
  @minute @second * 60
  @hour   @minute * 60
  @day    @hour * 24
  @week   @day * 7
  @divisor [@week, @day, @hour, @minute, @second, 1]

  defp sec_to_str(sec) do
    {_, [ms, s, m, h, d, w]} =
        Enum.reduce(@divisor, {sec,[]}, fn divisor,{n,acc} ->
          {rem(n,divisor), [div(n,divisor) | acc]}
        end)
    ["#{w} wk", "#{d} d", "#{h} hr", "#{m} min", "#{s}.#{ms} sec"]
    |> Enum.reject(fn str -> String.starts_with?(str, "0") end)
    |> Enum.join(", ")
  end
end
