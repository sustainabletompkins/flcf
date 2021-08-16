class CartItemsController < ApplicationController
  def create
    if user_signed_in?
      user_id = current_user.id
      @cart_item = CartItem.new(user_id: user_id, title: params[:title], cost: params[:cost], pounds: params[:pounds], session_id: params[:session_id])
    else
      # temporarily disabling recurring offsets
      # no params[:offset_interval] coming in, we will set it manually
      @cart_item = CartItem.new(user_id: nil, title: params[:title].titleize, cost: params[:cost], pounds: params[:pounds], offset_type: params[:offset_type], offset_interval: 'one_time', frequency: params[:frequency], session_id: params[:session_id])

    end

    if @cart_item.save

      @cart_items = if user_signed_in?
                      current_user.offsets.where(purchased: :false)
                    else
                      CartItem.where(session_id: params[:session_id], purchased: :false)
                    end

    end
  end

  def populate_cart
    @user_offsets = CartItem.where(session_id: params[:session_id], purchased: :false)
    puts @user_offsets.inspect
    if @user_offsets.present?
      respond_to do |format|
        format.js { render 'populate_cart' }
      end
    end
  end

  def destroy
    @offset = CartItem.find(params[:id])
    @id = @offset.id
    @offset.destroy
  end
end
