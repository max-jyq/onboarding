# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :todo_api,
  ecto_repos: [TodoApi.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :todo_api, TodoApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TodoApiWeb.ErrorHTML, json: TodoApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TodoApi.PubSub,
  live_view: [signing_salt: "KkidYUJN"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :todo_api, TodoApi.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  todo_api: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  todo_api: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Tell Oban how to find the repo and which plugins and queues to use
config :todo_api, Oban,
  repo: TodoApi.Repo,
  plugins: [
    {Oban.Plugins.Cron,
     timezone: "Australia/Melbourne",
     crontab: [
       {"* * * * *", TodoApi.Workers.CompleteDueTodosWorker},
       {"0 0 * * *", TodoApi.Workers.FetchWeatherWorker}
     ]}
  ],
  queues: [default: 10]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
