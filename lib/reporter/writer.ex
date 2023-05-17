defmodule Reporter.Writer do
  alias Reporter.History

  def build_report(agent, date) do
    data = History.get(agent, date)
    IO.inspect(data)
  end
end
