import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { TodoWorkspace } from "@/features/todos/components/TodoWorkspace";

export default function TodosPage() {
  return (
    <DashboardLayout
      eyebrow="Todos"
      title="Todos"
      subtitle="A dedicated route for manual CRUD, with room to grow into filters, detail views, and editing."
    >
      <TodoWorkspace />
    </DashboardLayout>
  );
}
