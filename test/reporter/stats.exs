defmodule Reporter.Stats.CalculateTest do
  use ExUnit.Case

  alias Reporter.Stats

  # def setup_all do
  #   plain_x = %{
  #     "customer_id" => "5695675564208",
  #     "discount_codes" => "",
  #     "discounts" => "45",
  #     "gross_revenue" => "29.99",
  #     "order_date" => "43832",
  #     "order_id" => "4015485354160",
  #     "order_type" => "non_subscription",
  #     "payment_gateway" => "paypal",
  #     "source_medium" => "paid_fb / cpc"
  #   }

  #   plain_acc = %{
  #     count: 1,
  #     discount_codes: %{},
  #     discounts: 0,
  #     gross_revenue: 0,
  #     non_subscriptions: 0,
  #     payment_gateway: %{},
  #     source_medium: %{},
  #     subscriptions: 0
  #   }

  #   %{plain_x: plain_x, plain_acc: plain_acc}
  # end

  describe "update_discounts/2" do
    test "update.discounts/2" do
      plain_x = %{
        "customer_id" => "5695675564208",
        "discount_codes" => "",
        "discounts" => "45",
        "gross_revenue" => "29.99",
        "order_date" => "43832",
        "order_id" => "4015485354160",
        "order_type" => "non_subscription",
        "payment_gateway" => "paypal",
        "source_medium" => "paid_fb / cpc"
      }

      plain_acc = %{
        count: 1,
        discount_codes: %{},
        discounts: 55,
        gross_revenue: 0,
        non_subscriptions: 0,
        payment_gateway: %{},
        source_medium: %{},
        subscriptions: 0
      }

      result = Stats.update_discounts(plain_acc, plain_x)
      IO.puts("result....#{inspect(result.discounts)}")

      assert Decimal.compare(result.discounts, Decimal.new("45.00"))
    end
  end

  describe "update_discount_codes/2" do
    test "with previous value update.discount_codes/2" do
      plain_x = %{
        "customer_id" => "5695675564208",
        "discount_codes" =>"xyz",
        "discounts" => "45",
        "gross_revenue" => "29.99",
        "order_date" => "43832",
        "order_id" => "4015485354160",
        "order_type" => "non_subscription",
        "payment_gateway" => "paypal",
        "source_medium" => "paid_fb / cpc"
      }

      plain_acc = %{
        count: 1,
        discount_codes: %{},
        discounts: 55,
        gross_revenue: 0,
        non_subscriptions: 0,
        payment_gateway: %{},
        source_medium: %{},
        subscriptions: 0
      }

      result = Stats.update_discount_codes(plain_acc, plain_x)
      IO.puts("result....#{inspect(result.discounts)}")

      assert Decimal.compare(result.discounts, Decimal.new("45.00"))
    end
  end

  test "withoot previous value update.discount_codes/2" do
    plain_x = %{
      "customer_id" => "5695675564208",
      "discount_codes" => "",
      "discounts" => "45",
      "gross_revenue" => "29.99",
      "order_date" => "43832",
      "order_id" => "4015485354160",
      "order_type" => "non_subscription",
      "payment_gateway" => "paypal",
      "source_medium" => "paid_fb / cpc"
    }

    plain_acc = %{
      count: 1,
      discount_codes: %{},
      discounts: 55,
      gross_revenue: 0,
      non_subscriptions: 0,
      payment_gateway: %{},
      source_medium: %{},
      subscriptions: 0
    }

    result = Stats.update_discounts_codes(plain_acc, plain_x)
    IO.puts("result....#{inspect(result.discounts)}")

    assert Decimal.compare(result.discounts, Decimal.new("45.00"))
  end
end
end
