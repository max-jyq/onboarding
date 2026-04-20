import { AppShell } from "@/components/layout/AppShell";
import { WeatherListPage } from "@/features/weather/components/WeatherListPage";

export default function WeatherPage() {
  return (
    <AppShell
      title="Weather"
      subtitle="A second domain route to show how the frontend can stay organized when the backend has more than one resource."
    >
      <WeatherListPage />
    </AppShell>
  );
}
