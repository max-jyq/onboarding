export type Todo = {
  id: number;
  title: string;
  estimated_time: string | null;
  completed: boolean;
  completed_at: string | null;
  inserted_at?: string;
  updated_at?: string;
};

export type TodoPayload = {
  title: string;
  estimated_time: string | null;
  completed?: boolean;
};

export type TodoResponse = {
  data: Todo;
};

export type TodoListResponse = {
  data: Todo[];
};
