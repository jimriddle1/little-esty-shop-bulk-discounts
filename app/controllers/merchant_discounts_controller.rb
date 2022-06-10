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
    discount = merchant.discounts.new(discount_params)
    # binding.pry

    if discount.save
      redirect_to "/merchants/#{merchant.id}/discounts"
    else
      redirect_to "/merchants/#{merchant.id}/discounts/new"
      flash[:alert] = "Error: Please put in a valid discount (threshold greater than 0, discount inbetween 0 and 1)"
    end
    # binding.pry
    # redirect_to "/merchants/#{merchant.id}/discounts"
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

    if @discount.update(discount_params)
      redirect_to "/merchants/#{@merchant.id}/discounts/#{@discount.id}"
    else
      redirect_to "/merchants/#{@merchant.id}/discounts/#{@discount.id}/edit"
      flash[:alert] = "Error: Please put in a valid discount (threshold greater than 0, discount inbetween 0 and 1)"
    end

  end

  private

  def discount_params
    params.permit(:bulk_discount, :item_threshold)
  end

end
