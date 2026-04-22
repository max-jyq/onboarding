"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";

import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { deleteTodo, formatTodoDate, listTodos, updateTodo } from "@/features/todos/lib/api";
import type { Todo } from "@/features/todos/types";
import { listWeatherDays } from "@/features/weather/lib/api";
import type { WeatherDay } from "@/features/weather/types";

function formatTime(value: Date) {
  return new Intl.DateTimeFormat("en-AU", {
    hour: "numeric",
    minute: "2-digit",
    second: "2-digit",
  }).format(value);
}

function formatDayLabel(value: Date) {
  return new Intl.DateTimeFormat("en-AU", {
    weekday: "long",
    day: "numeric",
    month: "long",
  }).format(value);
}

function sortTodos(todos: Todo[]) {
  return [...todos].sort((left, right) => {
    if (left.completed !== right.completed) {
      return Number(left.completed) - Number(right.completed);
    }

    if (!left.estimated_time && !right.estimated_time) {
      return 0;
    }

    if (!left.estimated_time) {
      return 1;
    }

    if (!right.estimated_time) {
      return -1;
    }

    return new Date(left.estimated_time).getTime() - new Date(right.estimated_time).getTime();
  });
}

function toSydneyDateKey(value: Date) {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Australia/Sydney",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });

  return formatter.format(value);
}

function getTodayWeather(weatherDays: WeatherDay[], now: Date) {
  const today = toSydneyDateKey(now);

  return weatherDays.find((weatherDay) => weatherDay.date === today);
}

function isTodoOverdue(todo: Todo, now: Date) {
  if (todo.completed || !todo.estimated_time) {
    return false;
  }

  const dueAt = new Date(todo.estimated_time).getTime();

  if (Number.isNaN(dueAt)) {
    return false;
  }

  return dueAt < now.getTime();
}

const todoTabs = [
  { id: "open", label: "Open" },
  { id: "overdue", label: "Overdue" },
  { id: "completed", label: "Completed" },
] as const;

export default function Home() {
  const [now, setNow] = useState(() => new Date());
  const [todos, setTodos] = useState<Todo[]>([]);
  const [weatherDays, setWeatherDays] = useState<WeatherDay[]>([]);
  const [loadingTodos, setLoadingTodos] = useState(true);
  const [loadingWeather, setLoadingWeather] = useState(true);
  const [todoError, setTodoError] = useState<string | null>(null);
  const [weatherError, setWeatherError] = useState<string | null>(null);
  const [activeTodoId, setActiveTodoId] = useState<number | null>(null);
  const [activeTodoAction, setActiveTodoAction] = useState<"complete" | "delete" | null>(null);
  const [activeTab, setActiveTab] = useState<(typeof todoTabs)[number]["id"]>("open");

  const loadTodos = useCallback(async () => {
    setLoadingTodos(true);

    try {
      const result = await listTodos();
      setTodos(result.data);
      setTodoError(null);
    } catch (loadError) {
      setTodoError(loadError instanceof Error ? loadError.message : "Unable to load todos.");
    } finally {
      setLoadingTodos(false);
    }
  }, []);

  const loadWeather = useCallback(async () => {
    setLoadingWeather(true);
    try {
      const result = await listWeatherDays();
      setWeatherDays(result.data);
      setWeatherError(null);
    } catch (loadError) {
      setWeatherError(loadError instanceof Error ? loadError.message : "Unable to load weather.");
    } finally {
      setLoadingWeather(false);
    }
  }, []);

  useEffect(() => {
    const intervalId = window.setInterval(() => {
      setNow(new Date());
    }, 1000);

    return () => window.clearInterval(intervalId);
  }, []);

  useEffect(() => {
    loadTodos();
    loadWeather();
  }, [loadTodos, loadWeather]);

  useEffect(() => {
    const events = new EventSource("/api/todos/stream");

    events.addEventListener("todos_changed", () => {
      loadTodos();
    });

    return () => {
      events.close();
    };
  }, [loadTodos]);

  async function handleComplete(todo: Todo) {
    setActiveTodoId(todo.id);
    setActiveTodoAction("complete");

    try {
      await updateTodo(todo.id, {
        title: todo.title,
        estimated_time: todo.estimated_time,
        completed: true,
      });
      await loadTodos();
    } catch (actionError) {
      setTodoError(
        actionError instanceof Error ? actionError.message : "Unable to update this todo.",
      );
    } finally {
      setActiveTodoId(null);
      setActiveTodoAction(null);
    }
  }

  async function handleDelete(todoId: number) {
    setActiveTodoId(todoId);
    setActiveTodoAction("delete");

    try {
      await deleteTodo(todoId);
      await loadTodos();
    } catch (actionError) {
      setTodoError(
        actionError instanceof Error ? actionError.message : "Unable to delete this todo.",
      );
    } finally {
      setActiveTodoId(null);
      setActiveTodoAction(null);
    }
  }

  const todayWeather = getTodayWeather(weatherDays, now);
  const orderedTodos = sortTodos(todos);
  const openTodos = orderedTodos.filter((todo) => !todo.completed && !isTodoOverdue(todo, now));
  const overdueTodos = orderedTodos.filter((todo) => isTodoOverdue(todo, now));
  const completedTodos = orderedTodos.filter((todo) => todo.completed);
  const visibleTodos =
    activeTab === "completed" ? completedTodos : activeTab === "overdue" ? overdueTodos : openTodos;

  return (
    <DashboardLayout
      eyebrow="Dashboard"
      title="Time, weather, and todos"
    >
      <div className="space-y-6">
        <section className="grid gap-4 lg:grid-cols-[1.1fr_0.9fr]">
          <article className="rounded-4xl border border-zinc-300 p-6 shadow-sm">
            <p className="text-xs font-medium uppercase tracking-[0.24em] text-zinc-300">
              Local time
            </p>
            <p className="mt-6 text-5xl font-semibold tracking-tight sm:text-6xl">
              {formatTime(now)}
            </p>
            <p className="mt-3 text-base text-zinc-300">{formatDayLabel(now)}</p>
          </article>

          <article className="rounded-4xl border border-sky-100 p-6 shadow-sm">
            <div className="flex items-start justify-between gap-4">
              <div>
                <p className="text-xs font-medium uppercase tracking-[0.24em] text-zinc-500">
                  Weather
                </p>
                <h2 className="mt-2 text-2xl font-semibold tracking-tight text-zinc-950">
                  Today
                </h2>
              </div>
              <Link
                href="/weather"
                className="rounded-full border border-zinc-300 px-3 py-1.5 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
              >
                Open
              </Link>
            </div>

            <div className="mt-8">
              {loadingWeather ? (
                <p className="text-zinc-500">Loading weather...</p>
              ) : weatherError ? (
                <p className="text-red-700">{weatherError}</p>
              ) : todayWeather ? (
                <>
            
                  <div className="flex items-end gap-6">
                    <div>
                      <p className="text-sm uppercase tracking-[0.2em] text-zinc-400">High</p>
                      <p className="text-4xl font-semibold tracking-tight text-zinc-950">
                        {todayWeather.high_temp}°C
                      </p>
                    </div>
                    <div>
                      <p className="text-sm uppercase tracking-[0.2em] text-zinc-400">Low</p>
                      <p className="text-3xl font-semibold tracking-tight text-zinc-700">
                        {todayWeather.low_temp}°C
                      </p>
                    </div>
                  </div>
                </>
              ) : (
                <p className="text-zinc-500">No weather records yet.</p>
              )}
            </div>
          </article>
        </section>

        <section className="rounded-4xl border border-zinc-200 bg-white p-6 shadow-sm">
          <div className="flex flex-wrap items-center gap-3 sm:grid sm:grid-cols-[auto_1fr_auto] sm:items-center">
            <p className="shrink-0 text-xs font-medium uppercase tracking-[0.24em] text-zinc-500">
              Todos
            </p>
            <div className="grid w-full grid-cols-3 rounded-full border border-zinc-200 bg-zinc-100 p-1 sm:justify-self-end sm:mr-[25%] sm:w-84">
              {todoTabs.map((tab) => (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full whitespace-nowrap rounded-full px-5 py-2 text-center text-sm font-medium transition ${
                    activeTab === tab.id
                      ? "bg-white text-zinc-950 shadow-sm"
                      : "text-zinc-500 hover:text-zinc-900"
                  }`}
                >
                  {tab.label}
                </button>
              ))}
            </div>
            <p className="w-full text-sm text-zinc-500 sm:justify-self-end sm:w-38 sm:text-right">
              {activeTab === "completed"
                ? `${completedTodos.length} completed items`
                : activeTab === "overdue"
                  ? `${overdueTodos.length} overdue items`
                  : `${openTodos.length} open items`}
            </p>
          </div>

          <div className="mt-6 max-h-[60vh] overflow-y-auto pr-1">
            {loadingTodos ? (
              <div className="rounded-3xl border border-zinc-200 bg-zinc-50 p-6 text-zinc-500">
                Loading todos...
              </div>
            ) : todoError ? (
              <div className="rounded-3xl border border-red-200 bg-red-50 p-6 text-red-700">
                {todoError}
              </div>
            ) : visibleTodos.length === 0 ? (
              <div className="rounded-3xl border border-dashed border-zinc-300 bg-zinc-50 p-10 text-center text-zinc-500">
                {activeTab === "completed"
                  ? "No completed todos."
                  : activeTab === "overdue"
                    ? "No overdue todos."
                    : "No open todos."}
              </div>
            ) : (
              <ul className="space-y-3">
                {visibleTodos.map((todo) => {
                  const isActingOnTodo = activeTodoId === todo.id;
                  const overdue = isTodoOverdue(todo, now);

                  return (
                    <li
                      key={todo.id}
                      className="flex flex-col gap-4 rounded-3xl border border-zinc-200 bg-zinc-50 p-5 sm:flex-row sm:items-center sm:justify-between"
                    >
                      <Link
                        href={`/todos/${todo.id}`}
                        className="block flex-1 rounded-2xl outline-none transition hover:opacity-75 focus-visible:ring-2 focus-visible:ring-zinc-300"
                      >
                        <div className="flex flex-wrap items-center gap-3">
                          <h3 className="text-lg font-semibold text-zinc-950">{todo.title}</h3>
                          <span
                            className={`rounded-full px-3 py-1 text-xs font-medium ${
                              todo.completed
                                ? "bg-emerald-100 text-emerald-700"
                                : overdue
                                  ? "bg-red-100 text-red-700"
                                  : "bg-amber-100 text-amber-700"
                            }`}
                          >
                            {todo.completed ? "Completed" : overdue ? "Overdue" : "Open"}
                          </span>
                        </div>
                        <p className="mt-2 text-sm text-zinc-500">
                          Scheduled for {formatTodoDate(todo.estimated_time)}
                        </p>
                      </Link>

                      <div className="flex flex-wrap gap-2">
                        {!todo.completed ? (
                          <button
                            type="button"
                            onClick={() => handleComplete(todo)}
                            disabled={isActingOnTodo}
                            className="rounded-full bg-emerald-600 px-4 py-2 text-sm font-medium text-white transition hover:bg-emerald-500 disabled:cursor-not-allowed disabled:opacity-60"
                          >
                            {isActingOnTodo && activeTodoAction === "complete"
                              ? "Saving..."
                              : "Complete"}
                          </button>
                        ) : null}
                        <button
                          type="button"
                          onClick={() => handleDelete(todo.id)}
                          disabled={isActingOnTodo}
                          className="rounded-full border border-red-200 px-4 py-2 text-sm text-red-600 transition hover:bg-red-50 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                          {isActingOnTodo && activeTodoAction === "delete"
                            ? "Deleting..."
                            : "Delete"}
                        </button>
                      </div>
                    </li>
                  );
                })}
              </ul>
            )}
          </div>
        </section>
      </div>
    </DashboardLayout>
  );
}
