class PagesController < ApplicationController

  def home
    #@offsets = Offset.where(:purchased => :true)
  end

  def index
    @title = params[:page_name].titleize
    render params[:page_name]
  end
end
