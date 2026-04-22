defmodule TodoApi.Workers.FetchWeatherWorker do
  use Oban.Worker, queue: :default

  alias Oban.Job
  alias TodoApi.Weather
  alias TodoApi.Weather.Fetcher

  # impl表示这个是Oban.Worker的实现，perform函数是Oban.Worker必须实现的回调函数。
  # 意思是当Oban调度这个Worker执行任务时，会调用perform函数，并传入一个Job结构体作为参数。
  @impl Oban.Worker
  def perform(%Job{}) do
    # 1) 先从天气 API 拿“昨天 + 未来三天”
    # 2) 再整批写进数据库（同一天有旧数据就覆盖）
    with {:ok, days} <- Fetcher.fetch_melbourne_days(),
         {:ok, _rows} <- Weather.store_weather_days(days) do
      :ok
    else
      {:error, reason} ->
        # 返回 error 给 Oban，它会按重试策略自动再跑一次。
        {:error, reason}
    end
  end
end
