"use client";

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
    <div className="flex flex-col gap-8 xl:h-full">
      <section className="grid gap-8 lg:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)] xl:min-h-0 xl:flex-1">
        <div>
          <h2 className="mb-4 text-lg font-semibold text-zinc-900">Quick add</h2>
          <TodoForm submitLabel="Add todo" onSubmit={handleCreate} />
        </div>

        <div className="flex flex-col xl:min-h-0">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-zinc-900">All todos</h2>
            <p className="text-sm text-zinc-500">{todos.length} items</p>
          </div>
          <div className="max-h-[60vh] overflow-y-auto pr-1 xl:max-h-none xl:min-h-0 xl:flex-1">
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
        </div>
      </section>
    </div>
  );
}
