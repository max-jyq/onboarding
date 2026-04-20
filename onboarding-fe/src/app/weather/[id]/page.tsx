import { AppShell } from "@/components/layout/AppShell";
import { WeatherDetailCard } from "@/features/weather/components/WeatherDetailCard";

type WeatherDetailPageProps = {
  params: Promise<{ id: string }>;
};

export default async function WeatherDetailPage({ params }: WeatherDetailPageProps) {
  const { id } = await params;

  return (
    <AppShell
      title="Weather detail"
      subtitle="This page mirrors the todo detail route so the project structure stays predictable across domains."
    >
      <WeatherDetailCard weatherDayId={id} />
    </AppShell>
  );
}
