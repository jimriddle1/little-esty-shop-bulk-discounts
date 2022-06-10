class Discount < ApplicationRecord
  belongs_to :merchant
  validates_numericality_of :bulk_discount, less_than: 1
  validates_numericality_of :bulk_discount, greater_than: 0
  validates_numericality_of :item_threshold, greater_than: 0

end
