class OffsettersController < ApplicationController


  def create
    Offsetter.create(offsetter_params)
    redirect_to '/admin'
  end
  def update
    @user = Offsetter.find params[:id]

    respond_to do |format|
      if @user.update_attributes(offsetter_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def destroy
    Offsetter.find(params[:id]).destroy
    @id = params[:id]
  end

  private
  def offsetter_params
    params.require(:offsetter).permit(:name, :description,:avatar)
  end
end