defmodule TodoApi.Weather.Fetcher do
  # https://api.open-meteo.com/v1/forecast?latitude=-37.814&longitude=144.9633&hourly=temperature_2m&timezone=Australia%2FSydney&past_days=1&forecast_days=3
  @url "https://api.open-meteo.com/v1/forecast"
  @melbourne_lat -37.814
  @melbourne_lon 144.9633

  # 这个模块负责从外部天气API获取天气数据，并解析成我们需要的格式。
  def fetch_melbourne_days do
    params = [
      latitude: @melbourne_lat,
      longitude: @melbourne_lon,
      daily: "weather_code,temperature_2m_max,temperature_2m_min",
      timezone: "Australia/Sydney",
      past_days: 1,
      forecast_days: 3
    ]

    # get请求 发到@url地址，携带params参数
    case Req.get(@url, params: params) do
      {:ok, %Req.Response{status: 200, body: %{"daily" => daily}}} ->
        parse_daily(daily)

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      # 上面是非200，下面是请求失败
      {:error, reason} ->
        {:error, reason}
    end
  end

  # 因为我想获取前三后一段天气，所以我需要获取当前日期，来判断是否在返回的天气数据中有当天的天气数据，如果有就返回，没有就报错
  def fetch_melbourne_daily do
    with {:ok, days} <- fetch_melbourne_days(),
         {:ok, now} <- DateTime.now("Australia/Sydney") do
      today = DateTime.to_date(now)

      # enum和数据库里的enum不同。这里的enum是elixir里的一种数据结构，类似于列表或者map。
      # 是enum Elixir 的一个模块，用来操作list
      case Enum.find(days, &(&1.date == today)) do
        nil -> {:error, :today_not_found}
        day -> {:ok, day}
      end
    end
  end

  # defp是private function， def是public
  defp parse_daily(%{
         "time" => times,
         "temperature_2m_max" => highs,
         "temperature_2m_min" => lows
       })
       when is_list(times) and is_list(highs) and is_list(lows) do
    if length(times) == length(highs) and length(times) == length(lows) do
      days =
        #zip 捏起来
        Enum.zip([times, highs, lows])
        |> Enum.map(fn {date_str, high, low} ->
          # with ≈ try/catch，匹配成功就继续执行，匹配失败就返回错误
          with {:ok, date}
            <- Date.from_iso8601(date_str),
               true <- is_number(high),
               true <- is_number(low) do
            # ：ok是一个元组，表示成功的结果
            {:ok, %{date: date, high_temp: high * 1.0, low_temp: low * 1.0}}
          else
            # 下划线表示匹配所有其他情况
            _ -> :error
          end
        end)

      # find函数会遍历days列表，找到第一个满足条件的元素，如果找不到就返回nil。

      case Enum.find(days, &(&1 == :error)) do # 匿名函数来判断是不是error f n x -> x == :error end
      # nil表示没有error
        nil -> {:ok, Enum.map(days, fn {:ok, d} -> d end)}
        _ -> {:error, :invalid_daily_payload}
      end
    else
      {:error, :invalid_daily_payload}
    end
  end

  defp parse_daily(_), do: {:error, :invalid_daily_payload}
end
