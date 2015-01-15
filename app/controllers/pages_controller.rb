class PagesController < ApplicationController

  def home

  end

  def index
    @title = params[:page_name].titleize
    render params[:page_name]
  end
end
