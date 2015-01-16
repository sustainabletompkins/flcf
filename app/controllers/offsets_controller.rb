class OffsetsController < ApplicationController

  def create
    if user_signed_in?
      user_id = current_user.id
    else user_id = 0
    end

    @offset = Offset.new(:user_id=>user_id,:title=>params[:title],:cost=>params[:cost],:pounds=>params[:pounds],:session_id => params[:session_id],:quantity=>params[:quantity],:units=>params[:units])
    if @offset.save
      if user_signed_in?
        @offsets = current_user.offsets.where(:purchased=>:false)
      else
        @offsets = Offset.where(:session_id => params[:session_id],:purchased=>:false)
      end

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

  def duplicate
    offset = Offset.find(params[:offset_id])
    new_offset = offset.dup
    new_offset.purchased = false;
    if new_offset.save
      @offsets = current_user.offsets.where(:purchased=>:false)
      respond_to do |format|
        format.js {render 'offset-saved'}
      end
    end
  end

  def process_purchased
    current_user.session_id = nil
    current_user.save
    current_user.offsets.each do |o|
      o.purchased = true
      o.save
    end
    redirect_to :back
  end

end
