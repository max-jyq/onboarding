defmodule TodoApi.WeatherTest do
  use TodoApi.DataCase, async: true

  alias TodoApi.Weather
  alias TodoApi.Weather.WeatherDay

  @valid_attrs %{date: ~D[2026-04-20], high_temp: 24.5, low_temp: 13.2}
  @invalid_attrs %{date: nil, high_temp: nil, low_temp: nil}

  test "create_weather_day/1 creates a weather day" do
    assert {:ok, %WeatherDay{} = weather_day} = Weather.create_weather_day(@valid_attrs)
    assert weather_day.date == ~D[2026-04-20]
    assert weather_day.high_temp == 24.5
    assert weather_day.low_temp == 13.2
  end

  test "create_weather_day/1 returns errors for invalid data" do
    assert {:error, changeset} = Weather.create_weather_day(@invalid_attrs)

    assert %{
             date: ["can't be blank"],
             high_temp: ["can't be blank"],
             low_temp: ["can't be blank"]
           } = errors_on(changeset)
  end

  test "list_weather_days/0 returns weather data ordered by date" do
    {:ok, later_day} =
      Weather.create_weather_day(%{date: ~D[2026-04-21], high_temp: 20.0, low_temp: 10.0})

    {:ok, earlier_day} =
      Weather.create_weather_day(%{date: ~D[2026-04-19], high_temp: 18.0, low_temp: 8.0})

    assert [first, second] = Weather.list_weather_days()
    assert first.id == earlier_day.id
    assert second.id == later_day.id
  end
end
