defmodule TodoApiWeb.Router do
  use TodoApiWeb, :router

  # pipeline 是流水线，请求->进入相应piepline以及plug->controller
  # browser 以下的中间件会在浏览器访问时被使用（网页请求）
  pipeline :browser do
    # 接受html请求
    plug :accepts, ["html"]
    # 从session中获取数据
    plug :fetch_session
    # 读取一次性提示消息比如登陆成功/操作失败
    plug :fetch_live_flash
    # 给页面套一个外壳，可以统一header/footer
    plug :put_root_layout, html: {TodoApiWeb.Layouts, :root}
    # 防止csrf攻击（防止别的网站偷偷帮用户发送请求）
    plug :protect_from_forgery
    # 加安全头（防止xss）
    plug :put_secure_browser_headers
  end

  # api以下的中间件会在api请求时使用
  pipeline :api do
    plug :accepts, ["json"]
  end

  # 把不同的路径给不同的controller处理
  # scope是路径前缀，pipe_through是使用哪个pipeline
  # todoapiweb是controller所在的命名空间
  scope "/", TodoApiWeb do
    pipe_through :browser
    # get "/" 是访问根路径，PageController是控制器，:home是控制器里的函数
    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api" do
    get "/todos/stream", TodoApiWeb.TodoEventsController, :stream
  end

  scope "/api" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: TodoApiWeb.Schema
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:todo_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TodoApiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
