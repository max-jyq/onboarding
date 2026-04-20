"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { formatWeatherDate, getWeatherDay } from "../lib/api";
import type { WeatherDay } from "../types";

type WeatherDetailCardProps = {
  weatherDayId: string;
};

export function WeatherDetailCard({ weatherDayId }: WeatherDetailCardProps) {
  const [weatherDay, setWeatherDay] = useState<WeatherDay | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadWeatherDay() {
      try {
        const result = await getWeatherDay(weatherDayId);
        setWeatherDay(result.data);
      } catch (loadError) {
        setError(
          loadError instanceof Error ? loadError.message : "Unable to load weather record.",
        );
      } finally {
        setLoading(false);
      }
    }

    loadWeatherDay();
  }, [weatherDayId]);

  if (loading) {
    return (
      <div className="rounded-3xl border border-zinc-200 bg-white p-8 shadow-sm">
        Loading weather record...
      </div>
    );
  }

  if (error || !weatherDay) {
    return (
      <div className="rounded-3xl border border-red-200 bg-red-50 p-8 text-red-700">
        {error ?? "Weather record not found."}
      </div>
    );
  }

  return (
    <div className="rounded-3xl border border-zinc-200 bg-white p-8 shadow-sm">
      <p className="text-sm uppercase tracking-[0.2em] text-zinc-500">Weather detail</p>
      <h1 className="mt-3 text-4xl font-semibold tracking-tight text-zinc-950">
        {formatWeatherDate(weatherDay.date)}
      </h1>

      <dl className="mt-8 grid gap-6 sm:grid-cols-2">
        <div>
          <dt className="text-sm font-medium text-zinc-500">High</dt>
          <dd className="mt-2 text-2xl font-semibold text-zinc-950">{weatherDay.high_temp}°C</dd>
        </div>
        <div>
          <dt className="text-sm font-medium text-zinc-500">Low</dt>
          <dd className="mt-2 text-2xl font-semibold text-zinc-950">{weatherDay.low_temp}°C</dd>
        </div>
      </dl>

      <div className="mt-8">
        <Link
          href="/weather"
          className="inline-flex rounded-2xl border border-zinc-300 px-5 py-3 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
        >
          Back to weather list
        </Link>
      </div>
    </div>
  );
}
