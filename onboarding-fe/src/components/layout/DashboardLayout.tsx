"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";

type DashboardLayoutProps = {
  title: string;
  subtitle?: string;
  eyebrow?: string;
  actions?: ReactNode;
  children: ReactNode;
};

const navigation = [
  { href: "/", label: "Dashboard" },
  { href: "/todos", label: "Todos" },
  { href: "/weather", label: "Weather" },
];

function isActivePath(pathname: string, href: string) {
  if (href === "/") {
    return pathname === "/";
  }

  return pathname === href || pathname.startsWith(`${href}/`);
}

export function DashboardLayout({
  title,
  subtitle,
  eyebrow = "Workspace",
  actions,
  children,
}: DashboardLayoutProps) {
  const pathname = usePathname();

  return (
    <main className="min-h-screen px-4 py-4 text-zinc-900 sm:px-6 sm:py-6">
      <div className="grid min-h-[calc(100vh-2rem)] w-full gap-4 xl:grid-cols-[300px_minmax(0,1fr)]">
        <aside className="flex flex-col justify-between rounded-4xl border border-zinc-200 p-6 text-zinc-900 shadow-[0_24px_80px_rgba(15,23,42,0.08)]">
          <div>
            <div className="flex items-center gap-3">
              <div>
                <p className="text-xs uppercase tracking-normal text-zinc-500">Menu</p>
                <h2 className="text-lg font-semibold text-zinc-950">Onboarding</h2>
              </div>
            </div>

            <nav className="mt-4 space-y-2">
              {navigation.map((item) => {
                const active = isActivePath(pathname, item.href);

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`flex items-center justify-between rounded-2xl border px-4 py-3 text-sm font-medium transition ${
                      active
                        ? "border-zinc-950 text-zinc-950 shadow-sm"
                        : "border-transparent text-zinc-600 hover:border-zinc-300"
                    }`}
                  >
                    <span>{item.label}</span>
                    <span
                      className={`h-2.5 w-2.5 rounded-full border ${
                        active ? "border-zinc-950" : "border-zinc-300"
                      }`}
                    />
                  </Link>
                );
              })}
            </nav>
          </div>
        </aside>

        <section className="min-w-0 rounded-4xl border border-zinc-200 p-4 shadow-[0_24px_80px_rgba(15,23,42,0.08)] sm:p-6">
          <header className="rounded-[1.75rem] border border-zinc-200 p-6">
            <div className="flex flex-col gap-5 xl:flex-row xl:items-end xl:justify-between">
              <div className="min-w-0 flex-1">
                <p className="text-xs font-medium uppercase tracking-[0.28em] text-zinc-500">
                  {eyebrow}
                </p>
                <h1 className="mt-3 text-3xl font-semibold tracking-tight text-zinc-950 sm:text-4xl">
                  {title}
                </h1>
                {subtitle ? (
                  <p className="mt-3 text-sm leading-7 text-zinc-600 sm:text-base">{subtitle}</p>
                ) : null}
              </div>

              {actions ? <div className="flex flex-wrap gap-3">{actions}</div> : null}
            </div>
          </header>

          <div className="mt-6">{children}</div>
        </section>
      </div>
    </main>
  );
}
