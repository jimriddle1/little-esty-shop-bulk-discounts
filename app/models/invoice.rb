class Invoice < ApplicationRecord
  belongs_to :customer

  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :discounts, through: :merchants # need to test this

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
    # y = discounts.where('item_threshold <= ?', invoice_items.first.quantity).order(bulk_discount: :desc).first

    x = invoice_items.joins(:item)
                 .where(items: { merchant_id: merchant_id })
    accumulator = 0
    z = x.each do |invoice_item|
      if invoice_item.item.current_discount == nil
        accumulator += (invoice_item.quantity * invoice_item.unit_price)
      else
        accumulator += ((1 - invoice_item.item.current_discount.bulk_discount) * invoice_item.quantity * invoice_item.unit_price)
      end
    end

    return accumulator

    # binding.pry

                 # .sum('invoice_items.unit_price * invoice_items.quantity * items.current_discount_2')
        # z = invoice_items.joins(:discounts)
        #           .where('invoice_items.quantity = discounts.item_threshold')
        #          .select('invoice_items.id, MAX((invoice_items.unit_price * invoice_items.quantity)* (1 - discounts.bulk_discount)) AS applied_discount')
        #          .group('invoice_items.id')
        #          .sum(&:applied_discount)
        #
        #          binding.pry


  end

  def self.incomplete
    joins(:invoice_items)
      .where.not(invoice_items: { status: 2 })
      .group(:id)
      .select('invoices.*')
      .order(created_at: :asc)
  end

  def discounted_invoice_revenue
    x = invoice_items.joins(:item)

    accumulator = 0
    z = x.each do |invoice_item|
      if invoice_item.item.current_discount == nil
        accumulator += (invoice_item.quantity * invoice_item.unit_price)
      else
        accumulator += ((1 - invoice_item.item.current_discount.bulk_discount) * invoice_item.quantity * invoice_item.unit_price)
      end
    end
    # binding.pry

    return accumulator
  end

  def invoice_revenue
    invoice_items.joins(:item).sum('invoice_items.unit_price * invoice_items.quantity')
  end
end
