"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { formatTodoDate, getTodo } from "../lib/api";
import type { Todo } from "../types";

type TodoDetailCardProps = {
  todoId: string;
};

export function TodoDetailCard({ todoId }: TodoDetailCardProps) {
  const [todo, setTodo] = useState<Todo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadTodo() {
      try {
        const result = await getTodo(todoId);
        setTodo(result.data);
      } catch (loadError) {
        setError(loadError instanceof Error ? loadError.message : "Unable to load todo.");
      } finally {
        setLoading(false);
      }
    }

    loadTodo();
  }, [todoId]);

  if (loading) {
    return <div className="rounded-3xl border border-zinc-200 bg-white p-8">Loading todo...</div>;
  }

  if (error || !todo) {
    return (
      <div className="rounded-3xl border border-red-200 bg-red-50 p-8 text-red-700">
        {error ?? "Todo not found."}
      </div>
    );
  }

  return (
    <div className="rounded-3xl border border-zinc-200 bg-white p-8 shadow-sm">
      <div className="flex flex-wrap items-center gap-3">
        <h1 className="text-3xl font-semibold tracking-tight text-zinc-950">{todo.title}</h1>
        <span
          className={`rounded-full px-3 py-1 text-xs font-medium ${
            todo.completed ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700"
          }`}
        >
          {todo.completed ? "Completed" : "Open"}
        </span>
      </div>

      <dl className="mt-8 grid gap-6 sm:grid-cols-2">
        <div>
          <dt className="text-sm font-medium text-zinc-500">Estimated time</dt>
          <dd className="mt-2 text-base text-zinc-900">{formatTodoDate(todo.estimated_time)}</dd>
        </div>
        <div>
          <dt className="text-sm font-medium text-zinc-500">Completed at</dt>
          <dd className="mt-2 text-base text-zinc-900">{formatTodoDate(todo.completed_at)}</dd>
        </div>
        <div>
          <dt className="text-sm font-medium text-zinc-500">Created</dt>
          <dd className="mt-2 text-base text-zinc-900">{formatTodoDate(todo.inserted_at ?? null)}</dd>
        </div>
        <div>
          <dt className="text-sm font-medium text-zinc-500">Updated</dt>
          <dd className="mt-2 text-base text-zinc-900">{formatTodoDate(todo.updated_at ?? null)}</dd>
        </div>
      </dl>

      <div className="mt-8 flex flex-wrap gap-3">
        <Link
          href={`/todos/${todo.id}/edit`}
          className="rounded-2xl bg-zinc-900 px-5 py-3 text-sm font-medium text-white transition hover:bg-zinc-700"
        >
          Edit todo
        </Link>
        <Link
          href="/todos"
          className="rounded-2xl border border-zinc-300 px-5 py-3 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
        >
          Back to list
        </Link>
      </div>
    </div>
  );
}
