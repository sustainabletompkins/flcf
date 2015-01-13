class UsersController < ApplicationController

  before_filter :find_user_by_id

  def show

  end

  def shopping_cart
    @offsets = @user.offsets.where(:purchased => :false)
  end

  private

  def find_user_by_id
    @user = User.find(params[:id])
  end
end
