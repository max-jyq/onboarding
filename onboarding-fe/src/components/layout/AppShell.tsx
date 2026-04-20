"use client";

import Link from "next/link";
import type { ReactNode } from "react";

type AppShellProps = {
  title: string;
  subtitle?: string;
  children: ReactNode;
};

const navigation = [
  { href: "/", label: "Home" },
  { href: "/todos", label: "Todos" },
  { href: "/weather", label: "Weather" },
];

export function AppShell({ title, subtitle, children }: AppShellProps) {
  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,_#fafaf9_0%,_#f4f4f5_100%)] px-6 py-8 text-zinc-900">
      <div className="mx-auto max-w-6xl">
        <header className="mb-10 rounded-[2rem] border border-zinc-200 bg-white/80 p-6 shadow-sm backdrop-blur">
          <div className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <p className="text-sm font-medium uppercase tracking-[0.24em] text-zinc-500">
                Onboarding FE
              </p>
              <h1 className="mt-3 text-4xl font-semibold tracking-tight text-zinc-950">{title}</h1>
              {subtitle ? <p className="mt-3 max-w-2xl text-zinc-600">{subtitle}</p> : null}
            </div>

            <nav className="flex flex-wrap gap-2">
              {navigation.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="rounded-full border border-zinc-300 px-4 py-2 text-sm text-zinc-700 transition hover:border-zinc-500 hover:text-zinc-950"
                >
                  {item.label}
                </Link>
              ))}
            </nav>
          </div>
        </header>

        {children}
      </div>
    </main>
  );
}
