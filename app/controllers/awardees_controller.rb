class AwardeesController < ApplicationController

  def show_video
    @awardee = Awardee.find(params[:id])
    @video_id = @awardee.video_id
  end

  def create
    Awardee.create(awardee_params)
    redirect_to '/admin'
  end

  private
  def awardee_params
    params.require(:awardee).permit(:name, :bio, :video_id, :award_amount, :pounds_offset, :avatar)
  end
end