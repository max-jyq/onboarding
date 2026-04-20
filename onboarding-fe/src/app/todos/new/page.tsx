"use client";

import { useRouter } from "next/navigation";

import { AppShell } from "@/components/layout/AppShell";
import { TodoForm } from "@/features/todos/components/TodoForm";
import { createTodo } from "@/features/todos/lib/api";

export default function NewTodoPage() {
  const router = useRouter();

  async function handleSubmit(payload: {
    title: string;
    estimated_time: string | null;
    completed?: boolean;
  }) {
    await createTodo(payload);
    router.push("/todos");
    router.refresh();
  }

  return (
    <AppShell
      title="Create todo"
      subtitle="This page is intentionally separate from the list so you can feel how App Router pages map to product screens."
    >
      <div className="max-w-2xl">
        <TodoForm submitLabel="Create todo" onSubmit={handleSubmit} />
      </div>
    </AppShell>
  );
}
