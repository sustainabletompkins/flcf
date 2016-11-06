class AwardeesController < ApplicationController

  def show_video
    @awardee = Awardee.find(params[:id])
    @video_id = @awardee.video_id
  end

  def create
    Awardee.create(awardee_params)
    redirect_to '/admin'
  end

  def update
    @user = Awardee.find params[:id]

    respond_to do |format|
      if @user.update_attributes(awardee_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  private
  def awardee_params
    params.require(:awardee).permit(:name, :bio, :video_id, :award_amount, :pounds_offset, :avatar)
  end
end