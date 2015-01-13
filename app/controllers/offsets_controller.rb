class OffsetsController < ApplicationController

  def create
    @offset = Offset.new(:user_id=>1,:title=>params[:title],:cost=>params[:cost],:pounds=>params[:pounds],:quantity=>params[:quantity],:units=>params[:units])
    if @offset.save
      @offsets = Offset.all
      respond_to do |format|
        format.js {render 'offset-saved'}
      end
    end
  end

  def destroy
    @offset = Offset.find(params[:id])
    @id = @offset.id
    if @offset.destroy
      respond_to do |format|
        format.js {render 'offset-deleted'}
      end
    end
  end

end
