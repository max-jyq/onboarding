import { graphqlRequest } from "@/lib/api-client";

import type { WeatherDay, WeatherDayListResponse, WeatherDayResponse } from "../types";

type GraphQLWeatherDay = {
  id: string | number;
  date: string;
  highTemp: number;
  lowTemp: number;
  insertedAt?: string | null;
  updatedAt?: string | null;
};

function mapWeatherDay(weatherDay: GraphQLWeatherDay): WeatherDay {
  return {
    id: Number(weatherDay.id),
    date: weatherDay.date,
    high_temp: weatherDay.highTemp,
    low_temp: weatherDay.lowTemp,
    inserted_at: weatherDay.insertedAt ?? undefined,
    updated_at: weatherDay.updatedAt ?? undefined,
  };
}

export async function listWeatherDays(): Promise<WeatherDayListResponse> {
  const data = await graphqlRequest<{ weatherDays: GraphQLWeatherDay[] }>(`
    query ListWeatherDays {
      weatherDays {
        id
        date
        highTemp
        lowTemp
        insertedAt
        updatedAt
      }
    }
  `);

  return { data: data.weatherDays.map(mapWeatherDay) };
}

export async function getWeatherDay(id: string | number): Promise<WeatherDayResponse> {
  const data = await graphqlRequest<
    { weatherDay: GraphQLWeatherDay | null },
    { id: string | number }
  >(
    `
      query GetWeatherDay($id: ID!) {
        weatherDay(id: $id) {
          id
          date
          highTemp
          lowTemp
          insertedAt
          updatedAt
        }
      }
    `,
    { id },
  );

  if (!data.weatherDay) {
    throw new Error("Weather record not found.");
  }

  return { data: mapWeatherDay(data.weatherDay) };
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
