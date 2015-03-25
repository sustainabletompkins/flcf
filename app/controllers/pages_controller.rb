class PagesController < ApplicationController

  def home
    if user_signed_in?
      @saved_offsets = current_user.offsets.where(:purchased=>:true)
    end
    @recent_offsets = Offset.where(:purchased=>:true).order(id: :desc).limit(5)
  end

  def index
    render params[:page_name], :layout => "full"
  end

  def offset_log
    @offsets = Offset.where(:purchased => :true)
  end

end
