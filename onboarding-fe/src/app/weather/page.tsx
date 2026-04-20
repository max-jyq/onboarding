import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { WeatherListPage } from "@/features/weather/components/WeatherListPage";

export default function WeatherPage() {
  return (
    <DashboardLayout
      eyebrow="Weather"
      title="Weather"
      subtitle="A second domain route to show how the frontend can stay organized when the backend has more than one resource."
    >
      <WeatherListPage />
    </DashboardLayout>
  );
}
