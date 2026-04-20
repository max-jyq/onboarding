"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import { createTodo, deleteTodo, listTodos } from "../lib/api";
import type { Todo } from "../types";
import { TodoForm } from "./TodoForm";
import { TodoList } from "./TodoList";

export function TodoWorkspace() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadTodos() {
    try {
      setError(null);
      const result = await listTodos();
      setTodos(result.data);
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : "Unable to load todos.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadTodos();
  }, []);

  async function handleCreate(payload: { title: string; estimated_time: string | null }) {
    await createTodo(payload);
    await loadTodos();
  }

  async function handleDelete(id: number) {
    await deleteTodo(id);
    await loadTodos();
  }

  return (
    <div className="space-y-8">
      <section className="rounded-[2rem] bg-[radial-gradient(circle_at_top_left,_#fef3c7,_transparent_55%),linear-gradient(135deg,_#ffffff,_#f4f4f5)] p-8 shadow-sm ring-1 ring-zinc-200">
        <div className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
          <div className="max-w-xl">
            <p className="text-sm font-medium uppercase tracking-[0.2em] text-zinc-500">
              Manual todos
            </p>
            <h1 className="mt-3 text-4xl font-semibold tracking-tight text-zinc-950">
              Keep the Phoenix backend honest with a real UI.
            </h1>
            <p className="mt-3 text-base leading-7 text-zinc-600">
              This page reads, creates, and deletes todos through your Absinthe GraphQL API so
              you can see the full Next.js to backend flow.
            </p>
          </div>
          <Link
            href="/todos/new"
            className="inline-flex rounded-2xl bg-zinc-900 px-5 py-3 text-sm font-medium text-white transition hover:bg-zinc-700"
          >
            Open full create page
          </Link>
        </div>
      </section>

      <section className="grid gap-8 lg:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]">
        <div>
          <h2 className="mb-4 text-lg font-semibold text-zinc-900">Quick add</h2>
          <TodoForm submitLabel="Add todo" onSubmit={handleCreate} />
        </div>

        <div>
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-zinc-900">All todos</h2>
            <p className="text-sm text-zinc-500">{todos.length} items</p>
          </div>
          {loading ? (
            <div className="rounded-3xl border border-zinc-200 bg-white p-8 text-zinc-500 shadow-sm">
              Loading todos...
            </div>
          ) : error ? (
            <div className="rounded-3xl border border-red-200 bg-red-50 p-8 text-red-700">
              {error}
            </div>
          ) : (
            <TodoList todos={todos} onDelete={handleDelete} />
          )}
        </div>
      </section>
    </div>
  );
}
