class MerchantDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:id])
    @discounts = @merchant.discounts
  end
  #
  def show
    @merchant = Merchant.find(params[:id])
    @discount = Discount.find(params[:discount_id])
  end
  #
  # def update
  #   # require "pry"; binding.pry
  #   merch = Merchant.find(params[:id])
  #   invoice = Invoice.find(params[:invoice_id])
  #   invoice_item = InvoiceItem.find(params[:invoice_item_id])
  #   invoice_item.update(status: params[:status])
  #   redirect_to "/merchants/#{merch.id}/invoices/#{invoice.id}"
  #
  #   # require "pry"; binding.pry
  # end

end
