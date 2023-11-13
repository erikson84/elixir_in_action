import Config

config :todolist, http_port: 5454

if Mix.env() != :dev do
  import_config "#{Mix.env()}.exs"
end
