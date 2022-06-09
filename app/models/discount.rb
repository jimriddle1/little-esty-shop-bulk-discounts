class Discount < ApplicationRecord
  belongs_to :merchant

  def self.find_valid_discount(invoice)
    binding.pry

  end

end
