defmodule Reporter.Scheduler do
  @moduledoc """
  Scheduler will schedule reading and writing data
  """

  alias Reporter.{Report, History, Writer}

  @doc """
  For now we'll execute manually.
  """
  def run(customer) do
    {:ok, agent} = History.start_link(%{})
    IO.puts("create report...")
    new_report = Report.create_report(customer)
    date = new_report.date
    IO.puts("Using date...#{date}")
    IO.puts("Put report in history")
    History.put(agent, date, new_report)
    IO.puts("build report ...")
    Writer.build_report(agent, date)
  end
end
