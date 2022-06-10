require 'rails_helper'

RSpec.describe Item do
    describe "relationships" do
        it { should belong_to :merchant }
        it { should have_many :invoice_items }
        it { should have_many(:invoices).through(:invoice_items) }
        it { should have_many(:discounts).through(:merchant) }
    end

    describe "instance methods" do
        before :each do
            @merch1 = Merchant.create!(name: 'Floopy Fopperations')
            @customer1 = Customer.create!(first_name: 'Joe', last_name: 'Bob')
            @item1 = @merch1.items.create!(name: 'Floopy Original', description: 'the best', unit_price: 450)
            @item2 = @merch1.items.create!(name: 'Floopy Updated', description: 'the better', unit_price: 950)
            @item3 = @merch1.items.create!(name: 'Floopy Retro', description: 'the OG', unit_price: 550)
            @item4 = @merch1.items.create!(name: 'Floopy Geo', description: 'the OG', unit_price: 550)
            @invoice1 = @customer1.invoices.create!(status: 2, updated_at: Time.parse("2012-03-30 14:54:09 UTC"))
            @invoice1.transactions.create!(result: 0)
            @invoice2 = @customer1.invoices.create!(status: 2)
            InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 0)
            InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice2.id, quantity: 10, unit_price: 1000, status: 0)
            InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 100, unit_price: 1000, status: 0)
            InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1000, status: 1)
            InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 1)
            InvoiceItem.create!(item_id: @item4.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1000, status: 2)

        end

        describe "#current_discount" do
          before :each do
              @merch2 = Merchant.create!(name: 'Floopy Changerations')
              @customer2 = Customer.create!(first_name: 'Joe', last_name: 'Bob')
              @item5 = @merch2.items.create!(name: 'Floopy Original', description: 'the best', unit_price: 450)
              @item6 = @merch2.items.create!(name: 'Floopy Updated', description: 'the better', unit_price: 950)

              @invoice5 = @customer2.invoices.create!(status: 2, updated_at: Time.parse("2012-03-30 14:54:09 UTC"))

          end
            it "tests example 1" do
              @discount1 = @merch2.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
              InvoiceItem.create!(item_id: @item5.id, invoice_id: @invoice5.id, quantity: 5, unit_price: 1000, status: 0)
              InvoiceItem.create!(item_id: @item6.id, invoice_id: @invoice5.id, quantity: 5, unit_price: 1000, status: 1)

              expect(@item5.current_discount).to eq(nil)
              expect(@item6.current_discount).to eq(nil)

            end

            it "tests example 2" do
              @discount1 = @merch2.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
              InvoiceItem.create!(item_id: @item5.id, invoice_id: @invoice5.id, quantity: 10, unit_price: 1000, status: 0)
              InvoiceItem.create!(item_id: @item6.id, invoice_id: @invoice5.id, quantity: 5, unit_price: 1000, status: 1)

              expect(@item5.current_discount).to eq(@discount1)
              expect(@item6.current_discount).to eq(nil)
            end

            it "tests example 3" do
              @discount1 = @merch2.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
              @discount2 = @merch2.discounts.create!(bulk_discount: 0.3, item_threshold: 15)
              InvoiceItem.create!(item_id: @item5.id, invoice_id: @invoice5.id, quantity: 12, unit_price: 1000, status: 0)
              InvoiceItem.create!(item_id: @item6.id, invoice_id: @invoice5.id, quantity: 15, unit_price: 1000, status: 1)

              expect(@item5.current_discount).to eq(@discount1)
              expect(@item6.current_discount).to eq(@discount2)
            end

            it "tests example 4" do
              @discount1 = @merch2.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
              @discount2 = @merch2.discounts.create!(bulk_discount: 0.15, item_threshold: 15)
              InvoiceItem.create!(item_id: @item5.id, invoice_id: @invoice5.id, quantity: 12, unit_price: 1000, status: 0)
              InvoiceItem.create!(item_id: @item6.id, invoice_id: @invoice5.id, quantity: 15, unit_price: 1000, status: 1)

              expect(@item5.current_discount).to eq(@discount1)
              expect(@item6.current_discount).to eq(@discount1)
            end

            it "tests example 5" do
              @discount1 = @merch2.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
              @discount2 = @merch2.discounts.create!(bulk_discount: 0.3, item_threshold: 15)

              @merch3 = Merchant.create!(name: 'Floopy Blasterations')
              @item7 = @merch3.items.create!(name: 'Some other item', description: 'the best', unit_price: 450)

              InvoiceItem.create!(item_id: @item5.id, invoice_id: @invoice5.id, quantity: 12, unit_price: 1000, status: 0)
              InvoiceItem.create!(item_id: @item6.id, invoice_id: @invoice5.id, quantity: 15, unit_price: 1000, status: 1)
              InvoiceItem.create!(item_id: @item7.id, invoice_id: @invoice5.id, quantity: 15, unit_price: 1000, status: 1)

              expect(@item5.current_discount).to eq(@discount1)
              expect(@item6.current_discount).to eq(@discount2)
              expect(@item7.current_discount).to eq(nil)
            end

        end

        describe "#find_invoice_id" do
            it "finds invoice id of a specific item" do
                expect(@item1.find_invoice_id).to eq(@invoice1.id)
            end
        end

        describe '#invoice_time' do
          it 'finds invoice creation dates of a specific item' do
            expect(@item1.invoice_time[0].created_at.strftime('%A %B %e %Y')).to eq(@invoice1.created_at.strftime('%A %B %e %Y'))
            expect(@item1.invoice_time[1].created_at.strftime('%A %B %e %Y')).to eq(@invoice2.created_at.strftime('%A %B %e %Y'))
            expect(@item1.invoice_time[2].created_at.strftime('%A %B %e %Y')).to eq(@invoice1.created_at.strftime('%A %B %e %Y'))
          end
        end

         describe "#item_best_day" do
            it 'finds the items highest revenue day' do
                expect(@item1.item_best_day).to eq('2012-03-30 14:54:09 UTC')
            end
        end
    end

    describe "class methods" do
        before :each do
            @merch1 = Merchant.create!(name: 'Floopy Fopperations')
            @customer1 = Customer.create!(first_name: 'Joe', last_name: 'Bob')
            @item1 = @merch1.items.create!(name: 'Floopy Original', description: 'the best', unit_price: 450)
            @item2 = @merch1.items.create!(name: 'Floopy Updated', description: 'the better', unit_price: 950)
            @item3 = @merch1.items.create!(name: 'Floopy Retro', description: 'the OG', unit_price: 550)
            @item4 = @merch1.items.create!(name: 'Floopy Geo', description: 'the OG', unit_price: 550)
            @invoice1 = @customer1.invoices.create!(status: 2)
            @invoice2 = @customer1.invoices.create!(status: 2)
            InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 0)
            InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1000, status: 1)
            InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 1)
            InvoiceItem.create!(item_id: @item4.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1000, status: 2)
        end
        describe "#enable / disable items" do
            it "returns all items based on status, enabled or disabled" do
                expect(Item.enabled_items).to eq([])
                expect(Item.disabled_items).to eq([@item1, @item2, @item3, @item4])

                @item1.update(status: 1)
                @item2.update(status: 1)

                expect(Item.enabled_items).to eq([@item1, @item2])
                expect(Item.disabled_items).to eq([@item3, @item4])
            end
        end

    end
end
