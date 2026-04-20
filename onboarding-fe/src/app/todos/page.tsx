import { AppShell } from "@/components/layout/AppShell";
import { TodoWorkspace } from "@/features/todos/components/TodoWorkspace";

export default function TodosPage() {
  return (
    <AppShell
      title="Todos"
      subtitle="A dedicated route for manual CRUD, with room to grow into filters, detail views, and editing."
    >
      <TodoWorkspace />
    </AppShell>
  );
}
