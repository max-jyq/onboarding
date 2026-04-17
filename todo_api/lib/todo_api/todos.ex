defmodule TodoApi.Todos do
  @moduledoc """
  Contains the todo domain logic, including CRUD operations and later any
  todo-specific business rules.
  """

  # 导入 Ecto.Query，后面写数据库查询时会用到里面的查询语法
  import Ecto.Query, warn: false

  # 给模块起短名字，后面写起来更简洁
  alias TodoApi.Repo
  alias TodoApi.Todos.Todo

  # 返回所有 todo，并按创建时间升序排序
  def list_todos do
    Repo.all(from t in Todo, order_by: [asc: t.inserted_at])
  end

  # 返回所有todos，但还没有完成的todo，按照创建时间省序
  def list_incomplete_todos do
    Repo.all(from t in Todo, where: t.completed == false, order_by: [asc: t.inserted_at])
  end

  # 根据 id 获取单个 todo
  # 如果查不到，会直接抛错
  def get_todo!(id), do: Repo.get!(Todo, id)

  # 创建新的 todo
  # attrs 是外部传入的数据，默认值是空 map
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  # 更新已有的 todo
  # %Todo{} = todo 表示这里要求传入的是一个 Todo 结构体
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  # 删除一个 todo
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  # 把一个todo标记为已完成，并记录完成时间
  def mark_todo_completed(%Todo{} = todo) do
    update_todo(todo, %{completed: true, completed_at: DateTime.utc_now()})
  end

  # 把一个todo标记为未完成，先检查是否是完成的，如果不是完成的，就不需要更新了，并记录完成时间
  def mark_todo_incomplete(%Todo{} = todo) do
    if todo.completed do
      update_todo(todo, %{completed: false, completed_at: nil})
    else
      {:ok, todo}
    end
  end

  # 所有已经overdue的todo，按照创建时间升序
  def list_overdue_todos do
    now = DateTime.utc_now()

    Repo.all(
      from t in Todo,
        where:
          t.completed == false and
            not is_nil(t.estimated_time) and
            t.estimated_time <= ^now,
        order_by: [asc: t.estimated_time]
    )
  end

  # 只生成 changeset，不真正写入数据库
  # 常用于表单校验或预览修改结果
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
