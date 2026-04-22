# Onboarding Project

A simple full-stack onboarding project:

- Frontend: Next.js + Tailwind CSS (`onboarding-fe`)
- Backend: Phoenix + GraphQL + Oban (`todo_api`)
- Features: Todo management and weather display (yesterday + today + next 3 days)

## Project Structure

- `onboarding-fe`: frontend pages and interactions
- `todo_api`: backend API, database, and scheduled jobs

## Local Setup

### 1) Start backend (port 4000)

```bash
cd todo_api
mix deps.get
mix ecto.setup
mix phx.server
```

### 2) Start frontend (port 3000)

Open a new terminal:

```bash
cd onboarding-fe
npm install
npm run dev
```

Open: `http://localhost:3000`

## Common Commands

### Backend

```bash
cd todo_api
mix test
mix format
```

### Frontend

```bash
cd onboarding-fe
npm run lint
```

## Weather Job Notes

- The backend fetches weather data from Open-Meteo using Sydney timezone.
- An Oban cron job runs daily and stores data in the database.
- Records for the same date are upserted (updated instead of duplicated).
