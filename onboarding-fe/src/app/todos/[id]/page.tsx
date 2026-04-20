import { AppShell } from "@/components/layout/AppShell";
import { TodoDetailCard } from "@/features/todos/components/TodoDetailCard";

type TodoDetailPageProps = {
  params: Promise<{ id: string }>;
};

export default async function TodoDetailPage({ params }: TodoDetailPageProps) {
  const { id } = await params;

  return (
    <AppShell
      title="Todo detail"
      subtitle="Dynamic routes in Next.js let you create one page component that can render every todo record."
    >
      <TodoDetailCard todoId={id} />
    </AppShell>
  );
}
