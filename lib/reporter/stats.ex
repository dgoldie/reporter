defmodule Reporter.Stats do
  Enum.filter([1, 2, 3], fn x -> rem(x, 2) == 0 end)

  def valid_gross_revenue_strings(data) do
    data
    |> Enum.filter(fn x -> validate_money_string(x["gross_revenue"]) end)
  end

  def validate_money(data) do
    data
    |> Enum.flat_map(fn x ->
      case Float.parse(x["gross_revenue"]) do
        # transform to float
        {_float, _rest} ->
          []

        # [Decimal.new(Float.to_string(float))]

        # skip the value
        :error ->
          IO.puts("***** invalid #{x["gross_revenue"]}")
      end
    end)
  end

  def validate_discounts(data) do
    data
    |> Enum.flat_map(fn x ->
      case Float.parse(x["discounts"]) do
        # transform to float; skip
        {_float, _rest} ->
          []

        # report
        :error ->
          IO.puts("***** invalid #{x["discounts"]}")
          x["discounts"]
      end
    end)
  end

  # validate with regex
  def validate_r_discounts(data) do
    # regex = "~r/^\d+.?\d{0,2}$/"

    data
    |> Enum.map(fn x ->
      if !String.match?(x["discounts"], ~r/^\d+.?\d{0,2}$/) do
        IO.puts(x["discounts"])
        # x["discounts"]
      end
    end)
  end

  def validate_r_gross_revenue(data) do
    # regex = "~r/^\d+.?\d{0,2}$/"

    data
    |> Enum.map(fn x ->
      if !String.match?(x["gross_revenue"], ~r/^\d+.?\d{0,2}$/) do
        IO.puts(x["gross_revenue"])
        x["gross_revenue"]
      end
    end)
  end

  # "discounts" => "0",
  # "gross_revenue" => "29.99",
  # def get_totals(data) do
  #   data
  #   |> Enum.reduce(%{count: 0, discounts: 0, gross_revenue: 0}, fn x, acc ->
  #     new_discounts = x["discounts"] |> string_to_float
  #     new_gross = x["gross_revenue"] |> string_to_float

  #     %{
  #       count: acc.count + 1,
  #       discounts: Float.round(acc.discounts + new_discounts, 2),
  #       gross_revenue: Float.round(acc.gross_revenue + new_gross, 2)
  #     }
  #   end)
  # end

  # decimal version
  def get_totals(data) do
    data
    |> Enum.reduce(%{count: 0, discounts: 0, gross_revenue: 0}, fn x, acc ->
      new_discounts = x["discounts"] |> Decimal.new()
      new_gross = x["gross_revenue"] |> Decimal.new()

      %{
        count: acc.count + 1,
        discounts: Decimal.add(Decimal.new(acc.discounts), new_discounts),
        gross_revenue: Decimal.add(Decimal.new(acc.gross_revenue), new_gross)
      }
    end)
  end

  def calc_order_types(data) do
    data
    |> Enum.reduce(%{count: 0, subscription: 0, non_subscription: 0}, fn x, acc ->
      new_gross = x["gross_revenue"] |> string_to_float

      case x["order_type"] do
        "subscription" ->
          %{
            count: acc.count + 1,
            subscription: Float.round(acc.subscription + new_gross, 2),
            non_subscription: acc.non_subscription
          }

        "non_subscription" ->
          %{
            count: acc.count + 1,
            subscription: acc.subscription,
            non_subscription: Float.round(acc.non_subscription + new_gross, 2)
          }
      end
    end)
  end

  def count_source_medium(data) do
    data
    |> Enum.reduce(%{count: 0, subscription: 0, non_subscription: 0}, fn x, acc ->
      new_gross = x["gross_revenue"] |> string_to_float

      case x["order_type"] do
        "subscription" ->
          %{
            count: acc.count + 1,
            subscription: Float.round(acc.subscription + new_gross, 2),
            non_subscription: acc.non_subscription
          }

        "non_subscription" ->
          %{
            count: acc.count + 1,
            subscription: acc.subscription,
            non_subscription: Float.round(acc.non_subscription + new_gross, 2)
          }
      end
    end)
  end

  def uniq(data) do
    data
    |> Enum.uniq_by(fn x -> x["source_medium"] end)
  end

  def calc_source_medium(data), do: group_by_attribute(data, "source_medium")
  def calc_discount_codes(data), do: group_by_attribute(data, "discount_codes")
  def calc_payment_gateway(data), do: group_by_attribute(data, "payment_gateway")

  # "source_medium", "discount_codes", "payment_gateway"
  defp group_by_attribute(data, attribute) do
    data
    |> Enum.group_by(fn x -> x[attribute] end)
    |> Enum.map(fn {k, v} ->
      {k, sum_gross(v)}
    end)
    |> Enum.sort_by(fn {_x, y} -> y end, :desc)
    |> Enum.take(3)
  end

  defp sum_gross(list) do
    Enum.reduce(list, 0, fn x, acc ->
      Float.round(acc + string_to_float(x["gross_revenue"]), 2)
    end)
  end

  # validate original value
  def validate_money_string(money_str) do
    :eq == Decimal.compare(Decimal.new(money_str), Decimal.round(money_str, 2))
  end

  # Float.parse("33.3456") |> elem(0) |> Float.round(2)
  defp string_to_float(string) do
    string
    |> Float.parse()
    |> elem(0)
    |> Float.round(2)
  end
end
