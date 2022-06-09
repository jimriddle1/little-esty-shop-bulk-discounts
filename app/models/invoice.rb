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
    # binding.pry

    # y = invoice_items.where('invoice_items.quantity > ?', 10)
    invoice_items.joins(:item)
                 # .group(:id)
                 .where('invoice_items.quantity >= ?', discounts.first.item_threshold)
                 .where(items: { merchant_id: merchant_id })
                 .sum('invoice_items.unit_price * invoice_items.quantity') *
                 (1 - discounts.first.bulk_discount)
     # binding.pry
  end

  def self.incomplete
    joins(:invoice_items)
      .where.not(invoice_items: { status: 2 })
      .group(:id)
      .select('invoices.*')
      .order(created_at: :asc)
  end

  def invoice_revenue
    invoice_items.joins(:item).sum('invoice_items.unit_price * invoice_items.quantity')
  end
end
