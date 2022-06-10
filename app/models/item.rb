class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :discounts, through: :merchant # need to test this

  enum status: %i[disabled enabled]

  def self.enabled_items
    where(status: 1)
  end

  def self.disabled_items
    where(status: 0)
  end

  def find_invoice_id
    invoice_items.first.invoice.id
  end

  def item_best_day
    invoices.joins(:transactions)
            .where(transactions: {result: 0})
            .group(:id) #always goes to refer to the original table / thing
            .select("invoices.*, sum(invoice_items.quantity) as sales")
            .order(sales: :desc)
            .first.updated_at
  end

  def invoice_time
    invoices.order(created_at: :asc)
  end


  def current_discount
    # binding.pry
    merchant.discounts
        .where('item_threshold <= ?', invoice_items.first.quantity)
        .order(bulk_discount: :desc)
        .first
  end

  def self.current_discount_2
    binding.pry
  end

end
