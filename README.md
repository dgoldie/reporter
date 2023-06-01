# Reporter

**TODO: Add description**

## Installation

## Process
Report.Cache starts a new ReportServer for a customer.
(Named after example in Elixir in Action)

iex(7)> {:ok, cache} = Reporter.ReportCache.start
{:ok, #PID<0.5228.0>}
iex(9)> ReportCache.server_process(cache, "customer-2")

### ReportServer - run manually
 {:ok, server} = ReportServer.start_link("customer-1")

## Reader - reads data for one date, one customer

alias Reporter.Reader
full = Reader.read("sourcemedium-test-project-dataset")

### Money
money vs ex_money vs Decimal

#### Discounts - many discounts have 3 digits precision ?? how to handle
4.049
2.429
11.696
4.858

Are discounts applied to gross revenue? revenue = gross_revenue - discounts

### History - stores 7 days of calculated data
            - could just be a Map in a GenServer.

### block it builder - block_it_builder.json

### TODO:

#### Report.Cache - update ?? if needed.

#### Scheduler - perhaps use Oban ??

#### Writer - create json file for daily report

#### csv_file - replace hard-coded file with dynamic data
              - store seven days data in History

#### Build report data in one pass
alias Reporter.Stats
Stats.calculate(full)

