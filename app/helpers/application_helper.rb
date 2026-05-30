module ApplicationHelper
  def format_currency(amount)
    number_to_currency(amount, unit: "Rp ", precision: 0, delimiter: ".")
  end
end
