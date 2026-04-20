"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";

import { getTodo, updateTodo } from "../lib/api";
import type { Todo } from "../types";
import { TodoForm } from "./TodoForm";

type TodoEditPageProps = {
  todoId: string;
};

export function TodoEditPage({ todoId }: TodoEditPageProps) {
  const router = useRouter();
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

  async function handleSubmit(payload: {
    title: string;
    estimated_time: string | null;
    completed?: boolean;
  }) {
    await updateTodo(todoId, payload);
    router.push(`/todos/${todoId}`);
    router.refresh();
  }

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
    <div className="space-y-6">
      <div>
        <p className="text-sm uppercase tracking-[0.2em] text-zinc-500">Edit todo</p>
        <h1 className="mt-2 text-4xl font-semibold tracking-tight text-zinc-950">{todo.title}</h1>
      </div>

      <TodoForm initialValue={todo} submitLabel="Save changes" onSubmit={handleSubmit} />

      <Link
        href={`/todos/${todoId}`}
        className="inline-flex rounded-2xl border border-zinc-300 px-5 py-3 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
      >
        Cancel
      </Link>
    </div>
  );
}
