import { apiRequest } from "@/lib/api-client";

import type { WeatherDay, WeatherDayListResponse, WeatherDayResponse } from "../types";

export function listWeatherDays() {
  return apiRequest<WeatherDayListResponse>("/api/weather");
}

export function getWeatherDay(id: string | number) {
  return apiRequest<WeatherDayResponse>(`/api/weather/${id}`);
}

export function formatWeatherDate(value: WeatherDay["date"]) {
  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat("en-AU", {
    dateStyle: "full",
  }).format(date);
}
