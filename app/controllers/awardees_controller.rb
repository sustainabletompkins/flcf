class AwardeesController < ApplicationController

  def show_video
    @awardee = Awardee.find(params[:id])
    @video_id = @awardee.video_id
  end


end