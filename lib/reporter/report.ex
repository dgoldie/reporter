defmodule Reporter.Report do
  @moduledoc """
  Report contains one day's work for one customer.
  """

  @csv_file "sourcemedium-test-project-dataset"

  alias Reporter.{Reader, Stats, ReportData, History, Writer}

  def run(customer) do
    {:ok, agent} = History.start_link(%{})
    IO.puts("create report...")
    new_report = create_report(customer)
    date = new_report.date
    IO.puts("Using date...#{date}")
    IO.puts("Put report in history")
    History.put(agent, date, new_report)
    IO.puts("build report ...")
    Writer.build_report(agent, date)
  end

  def create_report(customer) do
    data = Reader.read(@csv_file)
    IO.puts("Creating Report for #{customer}")
    date = data |> hd |> Map.get("order_date")
    totals = Stats.get_totals(data)
    order_types = Stats.calc_order_types(data) |> Map.delete(:count)
    source_medium = Stats.calc_source_medium(data)
    discount_codes = Stats.calc_discount_codes(data)
    payment_gateways = Stats.calc_payment_gateway(data)

    %ReportData{
      date: date,
      count: totals.count,
      orders: totals.count,
      discounts: totals.discounts |> Decimal.round(2) |> Decimal.to_float(),
      revenue: totals.gross_revenue |> Decimal.to_float(),
      order_type: order_types,
      source_medium: source_medium,
      discount_codes: discount_codes,
      payment_gateways: payment_gateways
    }
  end
end
