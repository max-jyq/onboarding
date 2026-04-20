"use client";

import { FormEvent, useState } from "react";

import { toDatetimeLocal } from "../lib/api";
import type { Todo, TodoPayload } from "../types";

type TodoFormProps = {
  initialValue?: Todo | null;
  submitLabel: string;
  onSubmit: (payload: TodoPayload) => Promise<void>;
};

export function TodoForm({ initialValue, submitLabel, onSubmit }: TodoFormProps) {
  const [title, setTitle] = useState(initialValue?.title ?? "");
  const [estimatedTime, setEstimatedTime] = useState(
    toDatetimeLocal(initialValue?.estimated_time ?? null),
  );
  const [completed, setCompleted] = useState(initialValue?.completed ?? false);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!title.trim()) {
      setError("Title is required.");
      return;
    }

    setSubmitting(true);
    setError(null);

    try {
      await onSubmit({
        title: title.trim(),
        estimated_time: estimatedTime ? new Date(estimatedTime).toISOString() : null,
        completed,
      });
    } catch (submitError) {
      setError(
        submitError instanceof Error ? submitError.message : "Unable to save this todo.",
      );
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="rounded-3xl border border-zinc-200 bg-white p-6 shadow-sm"
    >
      <div className="space-y-5">
        <div>
          <label className="mb-2 block text-sm font-medium text-zinc-700" htmlFor="title">
            Title
          </label>
          <input
            id="title"
            type="text"
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            className="w-full rounded-2xl border border-zinc-300 px-4 py-3 outline-none focus:border-zinc-500"
            placeholder="Plan onboarding tasks"
          />
        </div>

        <div>
          <label
            className="mb-2 block text-sm font-medium text-zinc-700"
            htmlFor="estimated_time"
          >
            Estimated time
          </label>
          <input
            id="estimated_time"
            type="datetime-local"
            value={estimatedTime}
            onChange={(event) => setEstimatedTime(event.target.value)}
            className="w-full rounded-2xl border border-zinc-300 px-4 py-3 outline-none focus:border-zinc-500"
          />
        </div>

        <label className="flex items-center gap-3 rounded-2xl bg-zinc-50 px-4 py-3 text-sm text-zinc-700">
          <input
            type="checkbox"
            checked={completed}
            onChange={(event) => setCompleted(event.target.checked)}
            className="h-4 w-4 rounded border-zinc-300"
          />
          Mark as completed
        </label>

        {error ? <p className="text-sm text-red-600">{error}</p> : null}

        <button
          type="submit"
          disabled={submitting}
          className="rounded-2xl bg-zinc-900 px-5 py-3 text-sm font-medium text-white transition hover:bg-zinc-700 disabled:opacity-60"
        >
          {submitting ? "Saving..." : submitLabel}
        </button>
      </div>
    </form>
  );
}
