import { apiRequest } from "@/lib/api-client";

import type { Todo, TodoListResponse, TodoPayload, TodoResponse } from "../types";

export function listTodos() {
  return apiRequest<TodoListResponse>("/api/todos");
}

export function getTodo(id: string | number) {
  return apiRequest<TodoResponse>(`/api/todos/${id}`);
}

export function createTodo(payload: TodoPayload) {
  return apiRequest<TodoResponse>("/api/todos", {
    method: "POST",
    body: JSON.stringify({ todo: payload }),
  });
}

export function updateTodo(id: string | number, payload: TodoPayload) {
  return apiRequest<TodoResponse>(`/api/todos/${id}`, {
    method: "PUT",
    body: JSON.stringify({ todo: payload }),
  });
}

export function deleteTodo(id: string | number) {
  return apiRequest<void>(`/api/todos/${id}`, {
    method: "DELETE",
  });
}

export function formatTodoDate(value: Todo["estimated_time"]) {
  if (!value) return "No date set";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return value;
  }

  return new Intl.DateTimeFormat("en-AU", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(date);
}

export function toDatetimeLocal(value: Todo["estimated_time"]) {
  if (!value) return "";

  const date = new Date(value);
  const timezoneOffset = date.getTimezoneOffset() * 60_000;
  const localDate = new Date(date.getTime() - timezoneOffset);

  return localDate.toISOString().slice(0, 16);
}
