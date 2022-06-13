class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  has_many :transactions, through: :invoice
  has_many :discounts, through: :item


  enum status: %w[pending packaged shipped]

  def self.item_revenue
    sum('quantity * unit_price')
  end

  def price_with_discount
    if item.current_discount == nil
      quantity * unit_price
    else
      quantity * unit_price * (1 - item.current_discount.bulk_discount)
    end
  end

end
