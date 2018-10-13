class AwardeesController < ApplicationController

  def show_video
    @awardee = Awardee.find(params[:id])
    @video_id = @awardee.video_id
    if @video_id.match(/[A-z]/)
      #this is a youtube video
      render 'show_youtube_video'
    else
      render 'show_video'  
    end

  end

  def create
    if simple_captcha_valid?
      Awardee.create(awardee_params)
      redirect_to '/admin'
    else
      render 'shared/captcha_failed'
    end
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

  def destroy
    Awardee.find(params[:id]).destroy
    @id = params[:id]
  end

  private
  def awardee_params
    params.require(:awardee).permit(:name, :bio, :video_id, :award_amount, :pounds_offset, :avatar,:captcha, :captcha_key)
  end
end
