require 'rails_helper'

RSpec.describe 'merchant invoices page', type: :feature do
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
    # InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice1.id, quantity: 10, unit_price: 1300, status: 1)
    # InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice1.id, quantity: 20, unit_price: 2000, status: 1)
    # InvoiceItem.create!(item_id: @item4.id, invoice_id: @invoice1.id, quantity: 5, unit_price: 1000, status: 2)
    # InvoiceItem.create!(item_id: @item4.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1000, status: 2)
    @discount1 = @merch1.discounts.create!(bulk_discount: 0.2, item_threshold: 10)
    @discount2 = @merch1.discounts.create!(bulk_discount: 0.3, item_threshold: 20)
  end

  it 'can see all the invoices(and id) that have at least one of my merchants items' do
  # As a merchant,
  # When I visit my merchant's invoices index (/merchants/merchant_id/invoices)
  # Then I see all of the invoices that include at least one of my merchant's items
  # And for each invoice I see its id

  visit "/merchants/#{@merch1.id}/invoices"

  expect(page).to have_content("Invoice #{@invoice1.id}")
  expect(page).to have_content("Status: #{@invoice1.status}")
  expect(page).to_not have_content("Invoice #{@invoice2.id}")


  end

  it 'has a link on each id to the merchant invoice show page' do
  # And each id links to the merchant invoice show page
    visit "/merchants/#{@merch1.id}/invoices"
    # binding.pry

    # save_and_open_page
    click_link "#{@invoice1.id}"

    expect(current_path).to eq("/merchants/#{@merch1.id}/invoices/#{@invoice1.id}")
  end
end
