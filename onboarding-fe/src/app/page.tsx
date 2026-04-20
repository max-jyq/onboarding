import Link from "next/link";

import { AppShell } from "@/components/layout/AppShell";

const cards = [
  {
    href: "/todos",
    eyebrow: "Manual CRUD",
    title: "Todos",
    description:
      "Use the dedicated todo section to create, inspect, edit, and delete records through the Phoenix backend.",
  },
  {
    href: "/weather",
    eyebrow: "Second domain",
    title: "Weather",
    description:
      "Browse stored weather records so the frontend mirrors the backend structure with more than one resource.",
  },
];

export default function Home() {
  return (
    <AppShell
      title="Onboarding frontend"
      subtitle="This home page acts like a small hub. The real product screens now live in dedicated App Router pages under /todos and /weather."
    >
      <section className="grid gap-6 lg:grid-cols-2">
        {cards.map((card) => (
          <Link
            key={card.href}
            href={card.href}
            className="group rounded-[2rem] border border-zinc-200 bg-white p-8 shadow-sm transition hover:-translate-y-1 hover:shadow-md"
          >
            <p className="text-xs font-medium uppercase tracking-[0.2em] text-zinc-500">
              {card.eyebrow}
            </p>
            <h2 className="mt-4 text-3xl font-semibold tracking-tight text-zinc-950">
              {card.title}
            </h2>
            <p className="mt-3 max-w-xl text-base leading-7 text-zinc-600">{card.description}</p>
            <p className="mt-6 text-sm font-medium text-zinc-900 transition group-hover:translate-x-1">
              Open page -
            </p>
          </Link>
        ))}
      </section>
    </AppShell>
  );
}
