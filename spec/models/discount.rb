require 'rails_helper'

RSpec.describe Discount do
    describe "relationships" do
        it { should belong_to :merchant }
        it { should have_many(:transactions).through(:invoices) }
    end
end
