class OffsettersController < ApplicationController


  def create
    Offsetter.create(offsetter_params)
    redirect_to '/admin'
  end

  private
  def offsetter_params
    params.require(:offsetter).permit(:name, :description,:avatar)
  end
end