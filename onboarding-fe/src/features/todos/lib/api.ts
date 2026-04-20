import { graphqlRequest } from "@/lib/api-client";

import type { Todo, TodoListResponse, TodoPayload, TodoResponse } from "../types";

type GraphQLTodo = {
  id: string | number;
  title: string;
  estimatedTime: string | null;
  completed: boolean;
  completedAt: string | null;
  insertedAt?: string | null;
  updatedAt?: string | null;
};

function mapTodo(todo: GraphQLTodo): Todo {
  return {
    id: Number(todo.id),
    title: todo.title,
    estimated_time: todo.estimatedTime,
    completed: todo.completed,
    completed_at: todo.completedAt,
    inserted_at: todo.insertedAt ?? undefined,
    updated_at: todo.updatedAt ?? undefined,
  };
}

function toTodoInput(payload: TodoPayload) {
  return {
    title: payload.title,
    estimatedTime: payload.estimated_time,
    completed: payload.completed,
  };
}

export async function listTodos(): Promise<TodoListResponse> {
  const data = await graphqlRequest<{ todos: GraphQLTodo[] }>(`
    query ListTodos {
      todos {
        id
        title
        estimatedTime
        completed
        completedAt
        insertedAt
        updatedAt
      }
    }
  `);

  return { data: data.todos.map(mapTodo) };
}

export async function getTodo(id: string | number): Promise<TodoResponse> {
  const data = await graphqlRequest<{ todo: GraphQLTodo | null }, { id: string | number }>(
    `
      query GetTodo($id: ID!) {
        todo(id: $id) {
          id
          title
          estimatedTime
          completed
          completedAt
          insertedAt
          updatedAt
        }
      }
    `,
    { id },
  );

  if (!data.todo) {
    throw new Error("Todo not found.");
  }

  return { data: mapTodo(data.todo) };
}

export async function createTodo(payload: TodoPayload): Promise<TodoResponse> {
  const data = await graphqlRequest<{ createTodo: GraphQLTodo }, { input: ReturnType<typeof toTodoInput> }>(
    `
      mutation CreateTodo($input: TodoInput!) {
        createTodo(input: $input) {
          id
          title
          estimatedTime
          completed
          completedAt
          insertedAt
          updatedAt
        }
      }
    `,
    { input: toTodoInput(payload) },
  );

  return { data: mapTodo(data.createTodo) };
}

export async function updateTodo(id: string | number, payload: TodoPayload): Promise<TodoResponse> {
  const data = await graphqlRequest<
    { updateTodo: GraphQLTodo },
    { id: string | number; input: ReturnType<typeof toTodoInput> }
  >(
    `
      mutation UpdateTodo($id: ID!, $input: TodoInput!) {
        updateTodo(id: $id, input: $input) {
          id
          title
          estimatedTime
          completed
          completedAt
          insertedAt
          updatedAt
        }
      }
    `,
    { id, input: toTodoInput(payload) },
  );

  return { data: mapTodo(data.updateTodo) };
}

export async function deleteTodo(id: string | number): Promise<void> {
  await graphqlRequest<{ deleteTodo: boolean }, { id: string | number }>(
    `
      mutation DeleteTodo($id: ID!) {
        deleteTodo(id: $id)
      }
    `,
    { id },
  );
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
