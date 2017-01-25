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

  def manual_create
    if simple_captcha_valid?
      pounds = params[:offset][:cost].to_i * 80
      @offset = Offset.create(:purchased => 'TRUE',:user_id=>'0',:name=>params[:offset][:name], :title=>params[:offset][:title],:cost=>params[:offset][:cost],:pounds=>pounds,:email => params[:user_email],:zipcode=>params[:offset][:zipcode])
      @stat = Stat.all.first
      @stat.increment!(:pounds, pounds)
      @stat.increment!(:dollars, params[:offset][:cost].to_f)
      if params[:team].to_i > 0
        @team = Team.find(params[:team])
        @team.update_attribute(:members, 1)
        @team.increment!(:pounds, pounds)
        TeamMember.create(:email => params[:user_email], :name=> params[:member_name], :offsets => 1, :team_id=>@team.id)
        @offset.update_attribute(:team_id,@team.id)
        @offset.update_attribute(:name,params[:member_name])
      elsif params[:member_name].length > 0
        @i=Individual.create(:email => params[:user_email], :name=> params[:member_name], :pounds => pounds, :count=>'1')
        @offset.update_attribute(:individual_id,@i.id)
        @offset.update_attribute(:name,params[:member_name])
      end
      render 'created'
    else
      render 'shared/captcha_failed'
    end

  end

  def save_donation
    @pounds = params[:cost].to_i * 80
    @offset = Offset.create(:session_id => params[:session_id],:user_id=>'0',:title=>'Donation',:cost=>params[:cost],:name=>params[:name], :zipcode=>params[:zipcode],:pounds=>@pounds)

  end

  def add_name_and_zip
    if user_signed_in?
      user_id = current_user.id
    else user_id = 0
    end

    Offset.where(:session_id => params[:session_id]).update_all(:name=>params[:name], :zipcode=>params[:zipcode])

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

  def populate_cart
    @user_offsets = Offset.where(:session_id=>params[:session_id], :purchased=>:false)
    if @user_offsets.present?
      respond_to do |format|
        format.js {render 'populate_cart'}
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
