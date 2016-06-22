defmodule TodoApp.Web do
  use Plug.Router

  alias TodoApp.{TodoCache, TodoServer, TodoEntry}

  def start_server do
    case Application.get_env(:todo_app, :port) do
      nil -> raise("Web server port is not specified!")
      port -> Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
    end
  end

  def init(_) do
    :ok
  end

  plug :match
  plug :dispatch

  post "/todo_list" do
    conn
    |> Plug.Conn.fetch_query_params
    |> add_entry
    |> respond
  end

  defp add_entry(conn) do
    conn.params["todo_list"]
    |> TodoCache.server_process
    |> TodoServer.add_entry(
      %TodoEntry{
        date: conn.params["date"],
        title: conn.params["title"]})
    assign(conn, :response, "ok")
  end

  defp respond(conn) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, conn.assigns[:response])
  end

  get "/" do
    conn
    |> Plug.Conn.fetch_query_params
    |> set_response
    |> respond
  end

  defp set_response(conn) do
    entries = conn.params["todo_list"]
    |> TodoCache.server_process
    |> TodoServer.entries
    assign(conn, :response, inspect entries)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
