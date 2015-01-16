class PagesController < ApplicationController

  def home
    if user_signed_in?
      @saved_offsets = current_user.offsets.where(:purchased=>:true)
    end
    @recent_offsets = Offset.where(:purchased=>:true).order(id: :desc).limit(5)
  end

  def index
    @title = params[:page_name].titleize
    render params[:page_name]
  end
end
