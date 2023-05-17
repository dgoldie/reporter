defmodule Reporter.ReportServer do
  use GenServer

  alias Reporter.Scheduler

  # Client

  # name: "customer-1", csv_file: "sourcemedium-test-project-dataset"
  def start_link(customer) do
    GenServer.start_link(__MODULE__, customer)
  end

  # Server

  def init(customer) do
    IO.puts("init...")
    IO.inspect(customer)
    Scheduler.run(customer)
    {:ok, customer}
  end
end
