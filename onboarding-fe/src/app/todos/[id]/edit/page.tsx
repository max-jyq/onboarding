import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { TodoEditPage } from "@/features/todos/components/TodoEditPage";

type EditTodoPageProps = {
  params: Promise<{ id: string }>;
};

export default async function EditTodoPage({ params }: EditTodoPageProps) {
  const { id } = await params;

  return (
    <DashboardLayout
      eyebrow="Edit"
      title="Edit todo"
      subtitle="This route reuses the same form component with a different submit action, which is a nice pattern to remember."
    >
      <TodoEditPage todoId={id} />
    </DashboardLayout>
  );
}
