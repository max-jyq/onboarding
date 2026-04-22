import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { WeatherListPage } from "@/features/weather/components/WeatherListPage";

export default function WeatherPage() {
  return (
    <DashboardLayout
      eyebrow="Weather"
      title="Weather"
    >
      <WeatherListPage />
    </DashboardLayout>
  );
}
