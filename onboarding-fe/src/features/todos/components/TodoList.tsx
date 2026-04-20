"use client";

import Link from "next/link";

import { formatTodoDate } from "../lib/api";
import type { Todo } from "../types";

type TodoListProps = {
  todos: Todo[];
  onDelete?: (id: number) => Promise<void>;
};

export function TodoList({ todos, onDelete }: TodoListProps) {
  if (todos.length === 0) {
    return (
      <div className="rounded-3xl border border-dashed border-zinc-300 bg-white p-8 text-center text-zinc-500">
        No todos yet. Start by creating one.
      </div>
    );
  }

  return (
    <ul className="space-y-3">
      {todos.map((todo) => (
        <li
          key={todo.id}
          className="flex flex-col gap-4 rounded-3xl border border-zinc-200 bg-white p-5 shadow-sm sm:flex-row sm:items-center sm:justify-between"
        >
          <div>
            <div className="flex items-center gap-3">
              <h3 className="text-lg font-semibold text-zinc-900">{todo.title}</h3>
              <span
                className={`rounded-full px-3 py-1 text-xs font-medium ${
                  todo.completed
                    ? "bg-emerald-100 text-emerald-700"
                    : "bg-amber-100 text-amber-700"
                }`}
              >
                {todo.completed ? "Completed" : "Open"}
              </span>
            </div>
            <p className="mt-2 text-sm text-zinc-500">
              Scheduled for {formatTodoDate(todo.estimated_time)}
            </p>
          </div>

          <div className="flex flex-wrap gap-2">
            <Link
              href={`/todos/${todo.id}`}
              className="rounded-2xl border border-zinc-300 px-4 py-2 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
            >
              View
            </Link>
            <Link
              href={`/todos/${todo.id}/edit`}
              className="rounded-2xl border border-zinc-300 px-4 py-2 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
            >
              Edit
            </Link>
            {onDelete ? (
              <button
                type="button"
                onClick={() => onDelete(todo.id)}
                className="rounded-2xl border border-red-200 px-4 py-2 text-sm text-red-600 transition hover:bg-red-50"
              >
                Delete
              </button>
            ) : null}
          </div>
        </li>
      ))}
    </ul>
  );
}
