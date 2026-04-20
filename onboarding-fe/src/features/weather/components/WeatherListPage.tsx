"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { formatWeatherDate, listWeatherDays } from "../lib/api";
import type { WeatherDay } from "../types";

export function WeatherListPage() {
  const [weatherDays, setWeatherDays] = useState<WeatherDay[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadWeatherDays() {
      try {
        const result = await listWeatherDays();
        setWeatherDays(result.data);
      } catch (loadError) {
        setError(
          loadError instanceof Error ? loadError.message : "Unable to load weather data.",
        );
      } finally {
        setLoading(false);
      }
    }

    loadWeatherDays();
  }, []);

  return (
    <div className="space-y-8">
      <section className="rounded-[2rem] bg-[radial-gradient(circle_at_top_left,_#dbeafe,_transparent_55%),linear-gradient(135deg,_#ffffff,_#f4f4f5)] p-8 shadow-sm ring-1 ring-zinc-200">
        <p className="text-sm font-medium uppercase tracking-[0.2em] text-zinc-500">Weather</p>
        <h1 className="mt-3 text-4xl font-semibold tracking-tight text-zinc-950">
          Daily weather snapshots from Phoenix.
        </h1>
        <p className="mt-3 max-w-2xl text-base leading-7 text-zinc-600">
          This page reads the weather records through your Absinthe GraphQL API so you can
          compare another domain next to todos.
        </p>
      </section>

      {loading ? (
        <div className="rounded-3xl border border-zinc-200 bg-white p-8 text-zinc-500 shadow-sm">
          Loading weather...
        </div>
      ) : error ? (
        <div className="rounded-3xl border border-red-200 bg-red-50 p-8 text-red-700">{error}</div>
      ) : weatherDays.length === 0 ? (
        <div className="rounded-3xl border border-dashed border-zinc-300 bg-white p-8 text-center text-zinc-500">
          No weather records yet.
        </div>
      ) : (
        <ul className="space-y-3">
          {weatherDays.map((weatherDay) => (
            <li
              key={weatherDay.id}
              className="flex flex-col gap-4 rounded-3xl border border-zinc-200 bg-white p-5 shadow-sm sm:flex-row sm:items-center sm:justify-between"
            >
              <div>
                <h2 className="text-lg font-semibold text-zinc-900">
                  {formatWeatherDate(weatherDay.date)}
                </h2>
                <p className="mt-2 text-sm text-zinc-500">
                  High {weatherDay.high_temp}°C, low {weatherDay.low_temp}°C
                </p>
              </div>

              <Link
                href={`/weather/${weatherDay.id}`}
                className="rounded-2xl border border-zinc-300 px-4 py-2 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
              >
                View details
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
