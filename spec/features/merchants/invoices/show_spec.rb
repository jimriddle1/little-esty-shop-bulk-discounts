require 'rails_helper'

RSpec.describe 'Merchant Invoice Show Page' do
    describe "Merchant Invoice Show Page" do
        before :each do
            @merch1 = Merchant.create!(name: 'Floopy Fopperations')
            @merch2 = Merchant.create!(name: 'Beauty Products 101')
            @customer1 = Customer.create!(first_name: 'Joe', last_name: 'Bob')
            @item1 = @merch1.items.create!(name: 'Floopy Original', description: 'the best', unit_price: 450)
            @item2 = @merch1.items.create!(name: 'Floopy Updated', description: 'the better', unit_price: 950)
            @item3 = @merch1.items.create!(name: 'Floopy Retro', description: 'the OG', unit_price: 550)
            @item4 = @merch2.items.create!(name: 'Floopy Geo', description: 'the OG', unit_price: 550)
            @invoice1 = @customer1.invoices.create!(status: 0)
            @invoice2 = @customer1.invoices.create!(status: 0)
            InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 0)
            InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice1.id, quantity: 10, unit_price: 1300, status: 1)
            InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice1.id, quantity: 20, unit_price: 2000, status: 1)
            InvoiceItem.create!(item_id: @item4.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 2)
            InvoiceItem.create!(item_id: @item4.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1000, status: 2)
            @discount1 = @merch1.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
            @discount2 = @merch1.discounts.create!(bulk_discount: 0.3, item_threshold: 20)
        end

        it "displays all items on invoice including name, quantity, price and status" do
            visit "/merchants/#{@merch1.id}/invoices/#{@invoice1.id}"
            # save_and_open_page
            within "#invoice-item-#{@item1.id}" do
                expect(page).to have_content("Name: Floopy Original")
                expect(page).to have_content("Quantity: 5")
                expect(page).to have_content("Unit Price: 1000")
                expect(page).to have_content("Status: pending")
                expect(page).to_not have_content("Name: Floopy Geo")
                expect(page).to_not have_content("Status: cancelled")
            end
            within "#invoice-item-#{@item3.id}" do
                expect(page).to have_content("Name: Floopy Retro")
                expect(page).to have_content("Quantity: 20")
                expect(page).to have_content("Unit Price: 2000")
                expect(page).to have_content("Status: packaged")
                expect(page).to_not have_content("Name: Floopy Geo")
                expect(page).to_not have_content("Quantity: 5")
                expect(page).to_not have_content("Unit Price: 1000")
                expect(page).to_not have_content("Status: Cancelled")
            end
            expect(page).to_not have_content("Name: Floopy Geo")
        end

        it 'shows the total revenue from all items on invoice' do

          visit "/merchants/#{@merch1.id}/invoices/#{@invoice1.id}"

          expect(page).to have_content("Total Revenue: 58000")
        end

        it 'will be able to update item on a merchants invoice' do
          visit "/merchants/#{@merch1.id}/invoices/#{@invoice1.id}"

          expect(page).to have_content("Status:")
          within "#invoice-item-#{@item3.id}" do
            select "shipped", :from => "status"
            click_button "Update Item Status"
          end

          expect(current_path).to eq("/merchants/#{@merch1.id}/invoices/#{@invoice1.id}")
          expect(page).to have_content("Status: shipped")
        end

        it 'gives me a discounted total revenue' do
          # As a merchant
          # When I visit my merchant invoice show page
          # Then I see the total revenue for my merchant from this invoice (not including discounts)
          # And I see the total discounted revenue for my merchant from this invoice which includes bulk discounts in the calculation
          visit "/merchants/#{@merch1.id}/invoices/#{@invoice1.id}"
          # @y.price_with_discount
          # @z.price_with_discount
          # save_and_open_page
          expect(page).to have_content("Total Revenue with Discounts: 43400")

        end

        it 'shows the current discount for each item' do
          # As a merchant
          # When I visit my merchant invoice show page
          # Next to each invoice item I see a link to the show page for the bulk discount that was applied (if any)
          visit "/merchants/#{@merch1.id}/invoices/#{@invoice1.id}"
          # save_and_open_page
          within "#invoice-item-#{@item1.id}" do
              expect(page).to have_content("No Discount Applied")
          end

          within "#invoice-item-#{@item2.id}" do
              expect(page).to have_link("Discount for #{@item2.name}")
          end

          within "#invoice-item-#{@item3.id}" do
              expect(page).to have_link("Discount for #{@item3.name}")
          end

          click_link("Discount for #{@item3.name}")
          expect(current_path).to eq("/merchants/#{@merch1.id}/discounts/#{@discount2.id}")

        end

    end

end
