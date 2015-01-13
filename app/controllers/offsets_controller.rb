class OffsetsController < ApplicationController

  def create
    @offset = Offset.new(:user_id=>1,:title=>params[:title],:cost=>params[:cost],:pounds=>params[:pounds],:quantity=>params[:quantity],:units=>params[:units])
    if @offset.save
      respond_to do |format|
        format.js {render 'offset-saved'}
      end
    end
  end

end
