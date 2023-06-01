defmodule Reporter.Stats do
  # alias Reporter.ReportData

  # def measure(function) do
  #   function
  #   |> :timer.tc
  #   |> elem(0)
  #   |> Kernel./(1_000_000)
  # end

  def calculate(data) do
    # %ReportData{}

    data
    |> Enum.reduce(
      %{
        count: 0,
        discounts: 0,
        gross_revenue: 0,
        subscriptions: 0,
        non_subscriptions: 0,
        source_medium: %{},
        discount_codes: %{},
        payment_gateway: %{}
      },
      fn x, acc ->
        # IO.puts("-----------------------------start ")
        IO.puts("-------------------------count: #{inspect(acc.count)}")

        acc
        |> update_count(x)
        |> update_discounts(x)
        |> update_discount_codes(x)
        |> update_gross_revenue(x)
        |> update_subscriptions(x)
        |> update_payment_gateway(x)
        |> update_source_medium(x)
      end
    )
  end

  def get_three_highest(data) do
    calc_source_medium(data)
    calc_payment_gateway(data)
    calc_discount_codes(data)
  end

  def update_count(acc, _x) do
    # IO.puts("--------------------part 1")

    {_old_value, new_acc} = get_and_update_in(acc.count, &{&1, &1 + 1})

    new_acc
  end

  def update_discounts(acc, x) do
    # IO.puts("--------------------part 2")

    discount = x["discounts"]

    {_old_value, new_acc} =
      get_and_update_in(acc.discounts, fn current_value ->
        result = add(current_value, discount)

        {current_value, result}
      end)

    new_acc
  end

  def update_discount_codes(acc, x) do
    # IO.puts("--------------------part 3")

    key = x["discount_codes"]
    discount = x["discounts"]

    {_my_current_value, new_acc} =
      get_and_update_in(
        acc,
        [:discount_codes, key],
        fn value ->
          if is_nil(value) do
            {value, discount}
          else
            {value, add(value, discount)}
          end
        end
      )

    new_acc
  end

  def update_gross_revenue(acc, x) do
    # IO.puts("--------------------part 4")
    gross = x["gross_revenue"]

    {_old_value, new_acc} =
      get_and_update_in(acc.gross_revenue, fn current_value ->
        result = add(current_value, gross)

        {current_value, result}
      end)

    new_acc
  end

  def update_subscriptions(acc, x) do
    # IO.puts("--------------------part 5")
    gross = x["gross_revenue"]
    # IO.puts("sub.....#{inspect(acc["subscription"])}")
    # IO.puts("non.....#{inspect(acc["non_subscription"])}")

    {_current, map_result} =
      case x["order_type"] do
        "subscription" ->
          # IO.puts("order type is subscription")

          get_and_update_in(
            acc.subscriptions,
            fn current_value ->
              result = add(acc.subscriptions, gross)
              {current_value, result}
            end
          )

        "non_subscription" ->
          # IO.puts("order type is non_subscription")

          get_and_update_in(
            acc.non_subscriptions,
            fn current_value ->
              # IO.inspect(current_value)
              result = add(acc.non_subscriptions, gross)
              {current_value, result}
            end
          )

        _ ->
          IO.puts("error: invalid order type")
      end

    map_result
  end

  def update_payment_gateway(acc, x) do
    # IO.puts("--------------------part 6")
    gross = x["gross_revenue"] |> Decimal.round(2)
    key = x["payment_gateway"]
    # IO.puts("key is #{key}")
    # IO.inspect(acc.payment_gateway)
    # IO.inspect(acc.payment_gateway[key])

    {_my_current_value, new_acc} =
      get_and_update_in(
        acc,
        [:payment_gateway, key],
        fn value ->
          # IO.puts("value is #{inspect(value)}")

          if is_nil(value) do
            {value, gross}
          else
            {value, add(acc.payment_gateway[key], Decimal.round(value, 2))}
          end
        end
      )

    # IO.puts("new acc....#{inspect(new_acc)}")
    new_acc
  end

  def update_source_medium(acc, x) do
    # IO.puts("--------------------part 7")

    gross = x["gross_revenue"] |> Decimal.round(2)
    key = x["source_medium"]
    # IO.puts("key is #{key}")
    # IO.inspect(acc.source_medium)
    # IO.inspect(acc.source_medium[key])

    {_my_current_value, new_acc} =
      get_and_update_in(
        acc,
        [:source_medium, key],
        fn value ->
          # IO.puts("value is #{inspect(value)}")

          if is_nil(value) do
            {value, gross}
          else
            {value, add(acc.source_medium[key], value)}
          end
        end
      )

    # IO.puts("new acc....#{inspect(new_acc)}")
    new_acc
  end

  defp add(n1, n2) do
    Decimal.add(
      Decimal.round(n1, 2),
      Decimal.round(n2, 2)
    )
    |> Decimal.round(2)
  end

  def take_source_medium(data), do: take_highest_in_order(data, :source_medium, 3)
  def take_payment_gateway(data), do: take_highest_in_order(data, :payment_gateway, 3)
  def take_discount_codes(data), do: take_highest_in_order(data, :discount_codes, 3)

  def take_highest_in_order(data, attribute, number) do
    highest =
      data[attribute]
      |> Enum.sort_by(fn {_x, y} -> y end, :desc)
      |> Enum.take(number)

    get_and_update_in(data, [attribute], fn x ->
      {x, highest}
    end)
  end

  # new_gross = x["gross_revenue"] |> Decimal.new() |> IO.inspect()

  # IO.puts(">>> acc")
  # IO.inspect(acc)
  # IO.puts("x")
  # IO.inspect(x["order_type"])

  # sub =
  #   case x["order_type"] do
  #     "subscription" ->
  #       %{
  #         subscriptions:
  #           Decimal.add(
  #             new_gross,
  #             Decimal.new(acc.subscriptions)
  #           ),
  #         non_subscriptions: acc.non_subscriptions
  #       }

  #     "non_subscription" ->
  #       %{
  #         subscriptions: acc.subscriptions,
  #         non_subscriptions:
  #           Decimal.add(
  #             acc.non_subscriptions,
  #             new_gross
  #           )
  #       }
  #   end

  # IO.puts("sub")
  # IO.inspect(sub)

  # Map.merge(result, sub)

  # count_source_medium
  # group_by_attribute(data, "source_medium")
  # IO.puts("acc source #{inspect(acc.source_medium)}")

  # IO.puts("source sub key #{inspect(x["source_medium"])}")
  # IO.inspect(result)

  # key = x["source_medium"]
  # gross = x["gross_revenue"]

  # source_sub =
  #   case get_in(data, [:source_medium, key]) do
  #     nil ->
  #       put_in(data, [:source_medium, key], gross)

  #     _ ->
  #       IO.puts("******************************** true")
  #       IO.inspect(key)
  #       IO.puts("acc #{inspect(acc)}")

  #       get_and_update_in(
  #         result,
  #         [:source_medium, key],
  #         &{&1, &1 + gross}
  #       )
  #   end

  # IO.puts("%%%%%%%%%%%%%%%%%% source sub #{inspect(source_sub)}")

  # |> Map.update(x["source_medium"], x["gross_revenue"], fn y ->
  #   Decimal.add(Decimal.new(y["gross_revenue"]), Decimal.new(acc.source_medium))
  # end)
  # Map.merge(result, source_sub)

  #       IO.puts("***************** end")

  #       # Map.merge(result, source_sub)
  #       Map.merge(acc, result)
  #     end
  #   )
  # end

  # def valid_gross_revenue_strings(data) do
  #   data
  #   |> Enum.filter(fn x -> validate_money_string(x["gross_revenue"]) end)
  # end

  # def validate_money(data) do
  #   data
  #   |> Enum.flat_map(fn x ->
  #     case Float.parse(x["gross_revenue"]) do
  #       # transform to float
  #       {_float, _rest} ->
  #         []

  #       # [Decimal.new(Float.to_string(float))]

  #       # skip the value
  #       :error ->
  #         IO.puts("***** invalid #{x["gross_revenue"]}")
  #     end
  #   end)
  # end

  # def validate_discounts(data) do
  #   data
  #   |> Enum.flat_map(fn x ->
  #     case Float.parse(x["discounts"]) do
  #       # transform to float; skip
  #       {_float, _rest} ->
  #         []

  #       # report
  #       :error ->
  #         IO.puts("***** invalid #{x["discounts"]}")
  #         x["discounts"]
  #     end
  #   end)
  # end

  # # validate with regex
  # def validate_r_discounts(data) do
  #   # regex = "~r/^\d+.?\d{0,2}$/"

  #   data
  #   |> Enum.map(fn x ->
  #     if !String.match?(x["discounts"], ~r/^\d+.?\d{0,2}$/) do
  #       IO.puts(x["discounts"])
  #       # x["discounts"]
  #     end
  #   end)
  # end

  # def validate_r_gross_revenue(data) do
  #   # regex = "~r/^\d+.?\d{0,2}$/"

  #   data
  #   |> Enum.map(fn x ->
  #     if !String.match?(x["gross_revenue"], ~r/^\d+.?\d{0,2}$/) do
  #       IO.puts(x["gross_revenue"])
  #       x["gross_revenue"]
  #     end
  #   end)
  # end

  # "discounts" => "0",
  # "gross_revenue" => "29.99",
  def get_totals(data) do
    data
    |> Enum.reduce(%{count: 0, discounts: 0, gross_revenue: 0}, fn x, acc ->
      new_discounts = x["discounts"] |> string_to_float
      new_gross = x["gross_revenue"] |> string_to_float

      %{
        count: acc.count + 1,
        discounts: Float.round(acc.discounts + new_discounts, 2),
        gross_revenue: Float.round(acc.gross_revenue + new_gross, 2)
      }
    end)
  end

  # decimal version
  # def get_totals(data) do
  #   data
  #   |> Enum.reduce(%{count: 0, discounts: 0, gross_revenue: 0}, fn x, acc ->
  #     new_discounts = x["discounts"] |> Decimal.new()
  #     new_gross = x["gross_revenue"] |> Decimal.new()

  #     %{
  #       count: acc.count + 1,
  #       discounts: Decimal.add(Decimal.new(acc.discounts), new_discounts),
  #       gross_revenue: Decimal.add(Decimal.new(acc.gross_revenue), new_gross)
  #     }
  #   end)
  # end

  def calc_order_types(data) do
    data
    |> Enum.reduce(%{count: 0, subscriptions: 0, non_subscriptions: 0}, fn x, acc ->
      new_gross = x["gross_revenue"] |> string_to_float

      case x["order_type"] do
        "subscription" ->
          %{
            count: acc.count + 1,
            subscription: Float.round(acc.subscriptions + new_gross, 2),
            non_subscription: acc.non_subscriptions
          }

        "non_subscription" ->
          %{
            count: acc.count + 1,
            subscription: acc.subscriptions,
            non_subscription: Float.round(acc.non_subscription + new_gross, 2)
          }
      end
    end)
  end

  #   def count_source_medium(data) do
  #     data
  #     |> Enum.reduce(%{count: 0, subscriptions: 0, non_subscriptions: 0}, fn x, acc ->
  #       new_gross = x["gross_revenue"] |> string_to_float

  #       case x["order_type"] do
  #         "subscription" ->
  #           %{
  #             count: acc.count + 1,
  #             subscriptions: Float.round(acc.subscriptions + new_gross, 2),
  #             non_subscriptions: acc.non_subscriptions
  #           }

  #         "non_subscription" ->
  #           %{
  #             count: acc.count + 1,
  #             subscriptions: acc.subscriptions,
  #             non_subscriptions: Float.round(acc.non_subscriptions + new_gross, 2)
  #           }
  #       end
  #     end)
  #   end

  #   def uniq(data) do
  #     data
  #     |> Enum.uniq_by(fn x -> x["source_medium"] end)
  #   end

  def calc_source_medium(data), do: group_by_attribute(data, "source_medium")
  def calc_discount_codes(data), do: group_by_attribute(data, "discount_codes")
  def calc_payment_gateway(data), do: group_by_attribute(data, "payment_gateway")

  #   # "source_medium", "discount_codes", "payment_gateway"
  defp group_by_attribute(data, attribute) do
    IO.puts("group by attribute #{attribute}\n")

    data
    |> Enum.group_by(fn x -> x[String.to_atom(attribute)] end)
    |> Enum.map(fn {k, v} ->
      {k, sum_gross(v)}
    end)
    |> Enum.sort_by(fn {_x, y} -> y end, :desc)
    |> Enum.take(3)
  end

  defp sum_gross(list) do
    IO.puts("....sum gross ***** #{inspect(list)}")

    Enum.reduce(list, 0, fn x, acc ->
      IO.inspect(acc)
      IO.inspect(x)

      # Decimal.add(
      #   acc,
      #   Decimal.new(x["gross_revenue"])
      # )
      # |> Decimal.round(2)

      # acc
      # Float.round(acc + string_to_float(x["gross_revenue"])
      Float.round(acc + string_to_float(x["gross_revenue"]))
    end)
  end

  defp string_to_float(string) do
    string
    |> Float.parse()
    |> elem(0)
    |> Float.round(2)
  end
end
