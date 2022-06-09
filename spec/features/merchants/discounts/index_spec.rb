require 'rails_helper'

RSpec.describe 'merchants discounts' do
  before :each do
    @merch1 = Merchant.create!(name: 'Floopy Fopperations')
    @customer1 = Customer.create!(first_name: 'Joe', last_name: 'Bob')
    @item1 = @merch1.items.create!(name: 'Floopy Original', description: 'the best', unit_price: 450)
    @item2 = @merch1.items.create!(name: 'Floopy Updated', description: 'the better', unit_price: 950)
    @item3 = @merch1.items.create!(name: 'Floopy Retro', description: 'the OG', unit_price: 550)
    @item4 = @merch1.items.create!(name: 'Floopy Geo', description: 'the OG', unit_price: 550)
    @invoice1 = @customer1.invoices.create!(status: 2)
    @invoice2 = @customer1.invoices.create!(status: 2)
    @invoice3 = @customer1.invoices.create!(status: 2)
    @invoice4 = @customer1.invoices.create!(status: 1)
    InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 0,
                        created_at: '2022-06-02 21:08:18 UTC')
    InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1000, status: 1,
                        created_at: '2022-06-01 21:08:15 UTC')
    InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice3.id, quantity: 5, unit_price: 1000, status: 1,
                        created_at: '2022-06-03 21:08:15 UTC')
    InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice4.id, quantity: 5, unit_price: 1000, status: 2,
                        created_at: '2022-06-03 21:08:15 UTC')

    @discount1 = @merch1.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
    @discount2 = @merch1.discounts.create!(bulk_discount: 0.3, item_threshold: 15)
  end

  it 'can show all the discounts and their attrs' do
    # As a merchant
    # When I visit my merchant dashboard
    # Then I see a link to view all my discounts
    # When I click this link
    # Then I am taken to my bulk discounts index page
    # Where I see all of my bulk discounts including their
    # percentage discount and quantity thresholds
    # And each bulk discount listed includes a link to its show page

    # binding.pry
    visit "/merchants/#{@merch1.id}/dashboard"

    click_link("View all discounts")
    expect(current_path).to eq("/merchants/#{@merch1.id}/discounts")

    within "#discount-#{@discount1.id}" do
      expect(page).to have_content("View Discount Details: #{@discount1.id}")
      expect(page).to have_content('Percentage Discount: 20.0%')
      expect(page).to have_content('Item Threshold: 10')

      expect(page).to_not have_content("View Discount Details: #{@discount2.id}")
      expect(page).to_not have_content('Percentage Discount: 30.0%')
      expect(page).to_not have_content('Item Threshold: 15')
    end

    within "#discount-#{@discount2.id}" do
      expect(page).to have_content("View Discount Details: #{@discount2.id}")
      expect(page).to have_content('Percentage Discount: 30.0%')
      expect(page).to have_content('Item Threshold: 15')

      expect(page).to_not have_content("View Discount Details: #{@discount1.id}")
      expect(page).to_not have_content('Percentage Discount: 20.0%')
      expect(page).to_not have_content('Item Threshold: 10')
    end

    click_link("#{@discount1.id}")
    expect(current_path).to eq("/merchants/#{@merch1.id}/discounts/#{@discount1.id}")

  end
end
