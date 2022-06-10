require 'rails_helper'

RSpec.describe Discount do
    describe "relationships" do
        it { should belong_to :merchant }
    end
    
    describe "validations" do
      it should validate_numericality_of(:bulk_discount).is_less_than(1)
      it should validate_numericality_of(:bulk_discount).is_greater_than(0)
      it should validate_numericality_of(:item_threshold).is_greater_than(0)
    end
end
