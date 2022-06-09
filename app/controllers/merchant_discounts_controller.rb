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

  def new
    @merchant = Merchant.find(params[:id])
    # binding.pry
  end

  def create
    merchant = Merchant.find(params[:id])
    merchant.discounts.create!(discount_params)
    # binding.pry
    redirect_to "/merchants/#{merchant.id}/discounts"
  end

  def destroy
    merchant = Merchant.find(params[:id])
    Discount.find(params[:discount_id]).destroy
    redirect_to "/merchants/#{merchant.id}/discounts"
  end
  #
  def edit
    @discount = Discount.find(params[:discount_id])
  end

  def update
    @merchant = Merchant.find(params[:id])
    @discount = Discount.find(params[:discount_id])
    
    @discount.update(discount_params)

    redirect_to "/merchants/#{@merchant.id}/discounts/#{@discount.id}"

  end

  private

  def discount_params
    params.permit(:bulk_discount, :item_threshold)
  end

end
