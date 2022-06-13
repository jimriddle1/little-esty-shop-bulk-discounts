class Invoice < ApplicationRecord
  belongs_to :customer

  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :discounts, through: :merchants

  enum status: ['in progress', 'cancelled', 'completed']

  def get_invoice_item(item_id)
    invoice_items.find_by(item_id: item_id)
  end

  def total_revenue(merchant_id)
    invoice_items.joins(:item)
                 .where(items: { merchant_id: merchant_id })
                 .sum('invoice_items.unit_price * invoice_items.quantity')
  end

  def total_discounted_revenue(merchant_id)
    invoice_items.joins(:item)
                 .where(items: { merchant_id: merchant_id })
                 .map do |invoice_item|
                    invoice_item.price_with_discount
                  end.sum
  end

  def self.incomplete
    joins(:invoice_items)
      .where.not(invoice_items: { status: 2 })
      .group(:id)
      .select('invoices.*')
      .order(created_at: :asc)
  end

  def discounted_invoice_revenue
    invoice_items.distinct.map do |invoice_item|
      invoice_item.price_with_discount
    end.sum
  end

  def invoice_revenue
    invoice_items.joins(:item).sum('invoice_items.unit_price * invoice_items.quantity')
  end
end
