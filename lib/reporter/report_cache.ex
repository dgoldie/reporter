defmodule Reporter.ReportCache do
  use GenServer

  alias Reporter.ReportServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, customer_name) do
    GenServer.call(cache_pid, {:server_process, customer_name})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, customer_name}, _, report_servers) do
    case Map.fetch(report_servers, customer_name) do
      {:ok, report_server} ->
        {:reply, report_server, report_servers}

      :error ->
        {:ok, new_server} = ReportServer.start_link(customer_name)

        {
          :reply,
          new_server,
          Map.put(report_servers, customer_name, new_server)
        }
    end
  end
end
