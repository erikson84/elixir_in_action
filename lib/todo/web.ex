defmodule Todo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: 5454],
      plug: __MODULE__
    )
  end

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    params = conn.params
    list_name = Map.fetch!(params, "list")
    title = Map.fetch!(params, "title")
    date = Map.fetch!(params, "date") |> Date.from_iso8601!()

    list_name
    |> Todo.Cache.server_process()
    |> Todo.Server.add_entry(%{date: date, title: title})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    params = conn.params

    list_name = Map.fetch!(params, "list")
    date = Map.fetch!(params, "date") |> Date.from_iso8601!()

    entries =
      list_name
      |> Todo.Cache.server_process()
      |> Todo.Server.retrieve(date)
      |> Enum.map_join("\n", &format_entry/1)

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, entries)
  end

  defp format_entry(%{date: date, title: title}) do
    "#{date}: #{title}"
  end
end
