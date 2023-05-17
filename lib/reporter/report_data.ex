defmodule Reporter.ReportData do
  defstruct date: nil,
            count: 0,
            revenue: 0.00,
            orders: 0,
            discounts: 0.00,
            order_type: %{},
            source_medium: %{},
            discount_codes: %{},
            payment_gateways: %{}
end
