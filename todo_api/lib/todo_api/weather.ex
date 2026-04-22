defmodule TodoApi.Weather do
  @moduledoc """
  Contains the weather domain logic for storing and querying daily weather data.
  """

  import Ecto.Query, warn: false

  alias TodoApi.Repo
  alias TodoApi.Weather.WeatherDay

  # 把天气按日期排好再给前端，列表看起来不会乱。
  def list_weather_days do
    Repo.all(from w in WeatherDay, order_by: [asc: w.date])
  end

  # 必须要有这条数据时用这个，查不到就直接报错。
  def get_weather_day!(id), do: Repo.get!(WeatherDay, id)

  # 想自己判断“有没有”就用这个，查不到会返回 nil。
  def get_weather_day(id), do: Repo.get(WeatherDay, id)

  # 按日期查，后面 upsert 会用到这个。
  def get_weather_day_by_date(date), do: Repo.get_by(WeatherDay, date: date)

  # 新增一条天气。
  def create_weather_day(attrs \\ %{}) do
    %WeatherDay{}
    |> WeatherDay.changeset(attrs)
    |> Repo.insert()
  end

  # 改已有天气。
  def update_weather_day(%WeatherDay{} = weather_day, attrs) do
    weather_day
    |> WeatherDay.changeset(attrs)
    |> Repo.update()
  end

  # 删一条天气。
  def delete_weather_day(%WeatherDay{} = weather_day) do
    Repo.delete(weather_day)
  end

  # 这个一般给表单或调试用，看校验错误会比较方便。
  def change_weather_day(%WeatherDay{} = weather_day, attrs \\ %{}) do
    WeatherDay.changeset(weather_day, attrs)
  end

  # 核心逻辑：同一天只保留一条。
  # 没有就插入，有了就更新，省得撞 unique(date)。
  def upsert_weather_day(%{date: date} = attrs) do
    case get_weather_day_by_date(date) do
      nil ->
        create_weather_day(attrs)

      weather_day ->
        update_weather_day(weather_day, attrs)
    end
  end

  # 给 worker 用的统一入口：只管把一天的天气存进去。
  # 如果数据库里这天已经有记录，就直接覆盖高低温，不会新增重复行。
  def store_weather_day(attrs) do
    %WeatherDay{}
    |> WeatherDay.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:high_temp, :low_temp, :updated_at]},
      conflict_target: [:date]
    )
  end

  # 一次存多天（比如“昨天 + 未来三天”）。
  # 只要中间有一天存失败，就马上返回错误，方便 worker 重试。
  def store_weather_days(days) when is_list(days) do
    Enum.reduce_while(days, {:ok, []}, fn attrs, {:ok, acc} ->
      case store_weather_day(attrs) do
        {:ok, weather_day} -> {:cont, {:ok, [weather_day | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, rows} -> {:ok, Enum.reverse(rows)}
      error -> error
    end
  end
end
