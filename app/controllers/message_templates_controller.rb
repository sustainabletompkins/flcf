class MessageTemplatesController < ApplicationController


  def update
    @user = MessageTemplate.find params[:id]

    respond_to do |format|
      if @user.update_attributes(prize_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  private
  def prize_params
    params.require(:message_template).permit(:body)
  end
end