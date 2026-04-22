import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { WeatherDetailCard } from "@/features/weather/components/WeatherDetailCard";

type WeatherDetailPageProps = {
  params: Promise<{ id: string }>;
};

export default async function WeatherDetailPage({ params }: WeatherDetailPageProps) {
  const { id } = await params;

  return (
    <DashboardLayout
      eyebrow="Weather"
      title="Weather detail"
    >
      <WeatherDetailCard weatherDayId={id} />
    </DashboardLayout>
  );
}
