defmodule TodoApi.Todos do
  # 导入 Ecto.Query，后面写数据库查询时会用到里面的查询语法
  import Ecto.Query, warn: false

  # 给模块起短名字，后面写起来更简洁
  alias TodoApi.Repo
  alias TodoApi.Todos.Todo

  # 返回所有 todo，并按创建时间升序排序
  def list_todos do
    Repo.all(from t in Todo, order_by: [asc: t.inserted_at])
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

  # 只生成 changeset，不真正写入数据库
  # 常用于表单校验或预览修改结果
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
