import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { TodoWorkspace } from "@/features/todos/components/TodoWorkspace";

export default function TodosPage() {
  return (
    <DashboardLayout
      eyebrow="Todos"
      title="Todos"
    >
      <TodoWorkspace />
    </DashboardLayout>
  );
}
